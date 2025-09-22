FROM node:10-alpine

WORKDIR /app
EXPOSE 4000

RUN npm install -g gitbook-cli
RUN npx gitbook init

# CMD ["npx", "gitbook", "serve"]
ENTRYPOINT [ "sh" ]