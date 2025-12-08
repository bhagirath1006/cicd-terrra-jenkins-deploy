FROM node:18-alpine AS builder

WORKDIR /app

# Create package.json
RUN printf '{\n  "name": "react-frontend",\n  "version": "1.0.0",\n  "scripts": {"start": "react-scripts start", "build": "react-scripts build"},\n  "dependencies": {"react": "^18.2.0", "react-dom": "^18.2.0", "react-scripts": "5.0.1"}\n}\n' > package.json

RUN npm install

# Create minimal app structure
RUN mkdir -p public src && \
    printf '<!DOCTYPE html><html><head><title>React</title></head><body><div id="root"></div></body></html>\n' > public/index.html && \
    printf 'import React from "react";\nimport ReactDOM from "react-dom/client";\nconst App = () => <div><h1>React App</h1></div>;\nconst root = ReactDOM.createRoot(document.getElementById("root"));\nroot.render(<App />);\n' > src/index.js && \
    printf 'export default function App() { return <h1>React Frontend</h1>; }\n' > src/App.js

RUN npm run build

FROM node:18-alpine

WORKDIR /app

RUN npm install -g serve

COPY --from=builder /app/build ./build

EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:3001 || exit 1

CMD ["serve", "-s", "build", "-l", "3001"]
