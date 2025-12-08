FROM node:18-alpine

WORKDIR /app

# Create package.json
RUN printf '{\n  "name": "nodejs-app",\n  "version": "1.0.0",\n  "scripts": {"start": "node app.js"},\n  "dependencies": {"express": "^4.18.2", "cors": "^2.8.5"}\n}\n' > package.json

# Create app.js
RUN printf 'const express = require("express");\nconst app = express();\napp.get("/", (req, res) => res.json({message: "Node.js API running"}));\napp.get("/health", (req, res) => res.json({status: "healthy"}));\napp.listen(3000, () => console.log("Server running on 3000"));\n' > app.js

# Create healthcheck.js
RUN printf 'const http = require("http");\nconst req = http.request({hostname: "localhost", port: 3000, path: "/health", method: "GET"}, (res) => {\n  if (res.statusCode === 200) process.exit(0);\n  else process.exit(1);\n});\nreq.on("error", () => process.exit(1));\nreq.end();\n' > healthcheck.js

RUN npm ci --only=production

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node healthcheck.js || exit 1

CMD ["npm", "start"]
