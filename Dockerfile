FROM node:20-alpine
RUN apk --update && mkdir -p /opt/app/logs && mkdir -p /opt/app/build
RUN addgroup -S app && adduser -S app -G app
# Install only production dependencies and not required to install development dependencies
RUN npm install --omit=dev
COPY dist/ /opt/app/build
COPY .env /opt/app/
RUN chown -R app:app /opt/app/
WORKDIR /opt/app/
#ENV NODE_ENV=production
CMD ["npm", "run", "start"]
EXPOSE 3000
USER app