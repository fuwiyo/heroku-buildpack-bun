import { Hono } from 'hono'

const app = new Hono()

app.get('/', (c) => {
  return c.json({
    message: 'Hello from Bun on Heroku!',
    timestamp: new Date().toISOString(),
    bun_version: Bun.version,
    runtime: 'Bun'
  })
})

app.get('/health', (c) => {
  return c.json({
    status: 'healthy',
    uptime: process.uptime(),
    memory: process.memoryUsage()
  })
})

app.get('/env', (c) => {
  return c.json({
    node_env: process.env.NODE_ENV || 'development',
    port: process.env.PORT || 3000,
    heroku: !!process.env.DYNO
  })
})

const port = parseInt(process.env.PORT || '3000')

console.log(`🚀 Server starting on port ${port}`)
console.log(`📦 Bun version: ${Bun.version}`)

export default {
  port,
  fetch: app.fetch,
}
