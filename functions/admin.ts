// Admin Function (Bun) - safe multi-action ops
// Env: SURR_URL, SURR_USER, SURR_PASS, SURR_NS, SURR_DB, ADMIN_SECRET, BACKUP_URL?

type Env = {
  SURR_URL?: string;
  SURR_USER?: string;
  SURR_PASS?: string;
  SURR_NS?: string;
  SURR_DB?: string;
  BACKUP_URL?: string;
  ADMIN_SECRET?: string;
};

const b64 = (s: string) => btoa(s);

async function surrealSql(env: Env, sql: string): Promise<Response> {
  const SURR_URL = env.SURR_URL || '';
  const SURR_USER = env.SURR_USER || 'root';
  const SURR_PASS = env.SURR_PASS || '';
  if (!SURR_URL || !SURR_PASS) {
    return new Response(
      JSON.stringify({ error: 'missing SURR_URL or SURR_PASS' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
  }
  const auth = `Basic ${b64(`${SURR_USER}:${SURR_PASS}`)}`;
  return fetch(`${SURR_URL.replace(/\/$/, '')}/sql`, {
    method: 'POST',
    headers: { Authorization: auth, 'Content-Type': 'application/json' },
    body: JSON.stringify({ sql }),
  });
}

async function actionBackup(env: Env): Promise<Response> {
  const ns = env.SURR_NS || 'app';
  const db = env.SURR_DB || 'app';
  const res = await surrealSql(
    env,
    `USE NS ${ns}; USE DB ${db}; EXPORT FOR DB;`
  );
  if (!res.ok) {
    return new Response(
      JSON.stringify({
        error: 'export failed',
        status: res.status,
        text: await res.text(),
      }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
  const blob = await res.arrayBuffer();
  if (env.BACKUP_URL) {
    const put = await fetch(env.BACKUP_URL, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/octet-stream' },
      body: blob,
    });
    if (!put.ok)
      return new Response(
        JSON.stringify({
          error: 'upload failed',
          status: put.status,
          text: await put.text(),
        }),
        { status: 502, headers: { 'Content-Type': 'application/json' } }
      );
    return new Response(
      JSON.stringify({ ok: true, uploaded: true, bytes: blob.byteLength }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  }
  return new Response(blob, {
    status: 200,
    headers: {
      'Content-Type': 'application/octet-stream',
      'Content-Disposition': `attachment; filename=backup-${ns}-${db}.surql`,
    },
  });
}

async function actionHealth(env: Env): Promise<Response> {
  const res = await surrealSql(env, 'INFO FOR DB;');
  const text = await res.text();
  return new Response(
    JSON.stringify({
      ok: res.ok,
      status: res.status,
      body: text.slice(0, 1024),
    }),
    {
      status: res.ok ? 200 : 500,
      headers: { 'Content-Type': 'application/json' },
    }
  );
}

async function actionExportTable(env: Env, table?: string): Promise<Response> {
  if (!table)
    return new Response(JSON.stringify({ error: 'missing table' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    });
  const ns = env.SURR_NS || 'app';
  const db = env.SURR_DB || 'app';
  const res = await surrealSql(
    env,
    `USE NS ${ns}; USE DB ${db}; SELECT * FROM ${table};`
  );
  const text = await res.text();
  return new Response(text, {
    status: res.ok ? 200 : 500,
    headers: { 'Content-Type': 'application/json' },
  });
}

async function actionMigrate(env: Env, src?: string): Promise<Response> {
  const ns = env.SURR_NS || 'app';
  const db = env.SURR_DB || 'app';
  let sql = `USE NS ${ns}; USE DB ${db};`;
  if (src) {
    const r = await fetch(src);
    if (!r.ok)
      return new Response(
        JSON.stringify({
          error: 'unable to fetch migration',
          status: r.status,
        }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    sql += ' ' + (await r.text());
  } else {
    sql += ' DEFINE TABLE users SCHEMAFULL;';
  }
  const res = await surrealSql(env, sql);
  const text = await res.text();
  return new Response(
    JSON.stringify({
      ok: res.ok,
      status: res.status,
      body: text.slice(0, 1024),
    }),
    {
      status: res.ok ? 200 : 500,
      headers: { 'Content-Type': 'application/json' },
    }
  );
}

export default async function handler(req: Request): Promise<Response> {
  const env = (globalThis as any).process?.env as Env;
  const SECRET = env.ADMIN_SECRET || '';
  const sig = req.headers.get('x-admin-signature') || '';
  if (!SECRET || sig !== SECRET)
    return new Response('unauthorized', { status: 401 });

  const url = new URL(req.url);
  const action = url.searchParams.get('action') || 'health';
  const table = url.searchParams.get('table') || undefined;
  const src = url.searchParams.get('src') || undefined;

  switch (action) {
    case 'backup':
      return actionBackup(env);
    case 'exportTable':
      return actionExportTable(env, table);
    case 'migrate':
      return actionMigrate(env, src);
    case 'health':
      return actionHealth(env);
    default:
      return new Response('unknown action', { status: 400 });
  }
}
