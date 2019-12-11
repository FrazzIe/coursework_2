FROM node:10
COPY server.js .
EXPOSE 8080
CMD [ "node", "server.js" ]