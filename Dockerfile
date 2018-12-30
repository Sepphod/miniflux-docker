FROM golang:1.11.4-alpine
ENV ADMIN_USER miniflux
ENV ADMIN_PASS test123
ENV ITEM_PER_PAGE 20

RUN apk --no-cache add ca-certificates expect git curl
RUN git clone https://github.com/miniflux/miniflux.git
RUN sed -i "s/100/${ITEM_PER_PAGE}/g" miniflux/ui/pagination.go
RUN sed -i '/<template id="keyboard-shortcuts">/,/<\/template>/d' miniflux/template/html/common/layout.html
RUN cd miniflux && \
last_version=`curl https://github.com/miniflux/miniflux/tags 2>/dev/null | grep "miniflux/releases/tag" | head -n 1 | sed 's#.*tag/\([^"]*\).*#\1#'` && \
make miniflux VERSION=$last_version && \
make clean && \
mv miniflux /usr/local/bin
RUN rm -rf miniflux
RUN apk del git

ADD entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh 
USER nobody

CMD /entrypoint.sh
