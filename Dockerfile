FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

FROM node:18-alpine AS runner
RUN adduser -u 1000 -g 1000 -D user && mkdir -p /home/user/app
WORKDIR /home/user/app
COPY --from=builder --chown=user:user /app/.output ./dist
COPY --from=builder --chown=user:user /app/node_modules ./node_modules
COPY --from=builder --chown=user:user /app/package.json ./
EXPOSE 7860  # HF默认端口（不是3000）
ENV NUXT_HOST=0.0.0.0 NUXT_PORT=7860
USER user
CMD ["yarn", "start"]  # 或 "node dist/server/index.mjs"
