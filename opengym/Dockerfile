# One container for Home Assistant: openGym's Node API plus nginx (static web + /api proxy),
# assembled from the project's official images.
ARG OPENGYM_TAG=latest
FROM ghcr.io/duartesantos8/opengym-web:${OPENGYM_TAG} AS web
FROM ghcr.io/duartesantos8/opengym-api:${OPENGYM_TAG}

USER root
RUN apk add --no-cache nginx gettext jq

# Static frontend and the nginx template from the web image
COPY --from=web /usr/share/nginx/html /usr/share/nginx/html
COPY --from=web /etc/nginx/templates/default.conf.template /etc/nginx/default.conf.template
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget --spider -q http://127.0.0.1:8080/api/health || exit 1
CMD ["/run.sh"]
