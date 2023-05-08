# libraries
Repository for my libraries

### Repository secrets

- `GIT_USERNAME`
- `GIT_EMAIL`
- `KEYSTORE_GIT_REPOSITORY`
- `KEYSTORE_ACCESS_TOKEN`

### Requirements

Platform:

- Node 18
- Dart 2.4+

Keystore folder structure:

- global
  - npm
    - token.txt `file with npm access token`

[//]: # (- libraries)

[//]: # (  - .env ``)

### Bootstrap project

```shell
git clone git@github.com:IIPEKOLICT/libraries.git
cd libraries
npm i
```

### Build all changed typescript libs

```shell
chmod +x scripts/typescript.sh
scripts/typescript.sh build
```

### Build and publish all changed typescript libs

```shell
chmod +x scripts/typescript.sh
scripts/typescript.sh publish
```

### Bootstrap new typescript library

```shell
chmod +x scripts/new.sh
scripts/new.sh --typescript $LIBRARY_NAME
cd typescript/$LIBRARY_NAME
```

### Link and use typescript library in other packages

Go to library folder, then:

```shell
npm run mount
```

After that go to package, where linked library need and:

```shell
npm link $LIBRARY_NAME
```

Now you can use linked library

### Test GitHub Actions workflow

Requirements:
- Docker
- Act utility
- .env file with repository secrets

```shell
act --secret-file .env
```
