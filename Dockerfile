FROM public.ecr.aws/spacelift/runner-terraform:latest
USER root

# Install packages
RUN apk update && apk add --update --no-cache npm
# Update NPM
RUN npm update -g
# Install cdk
RUN npm install -g aws-cdk
RUN cdk --version

# Install typescript
RUN npm install -g typescript ts-node @types/node

# Add Go
COPY --from=golang:1.19-alpine /usr/local/go/ /usr/local/go/

ENV PATH="/usr/local/go/bin:${PATH}"
RUN go version
