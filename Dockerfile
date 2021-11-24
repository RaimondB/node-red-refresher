FROM python:3-alpine

RUN apk add --no-cache bash curl

COPY ./get_token.py .
COPY ./update_node.sh .

RUN chmod +x ./update_node.sh

#CMD ./update_node.sh 
ENTRYPOINT ["/update_node.sh"]
CMD [""]