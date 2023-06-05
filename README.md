# libraries
Repository for my libraries

- [x] [Published npm packages](https://www.npmjs.com/search?q=%40evgenii-shcherbakov)
- [x] [Published pub.dev packages](https://pub.dev/packages?q=publisher%3Aiipekolict.infinityfreeapp.com)
- [x] [Published Maven Central packages](https://central.sonatype.com/search?smo=true&q=io.github.evgenii-shcherbakov)

---

### Repository secrets

- `KEYSTORE_HOST` keystore project API url
- `KEYSTORE_ACCESS_TOKEN` keystore API JWT access token

---

### Requirements

Platform:

- Node 18
- Dart 3
- Java 19

---

### Bootstrap project

```shell
git clone git@github.com:IIPEKOLICT/libraries.git
cd libraries
npm i
```

---

### TypeScript

##### Bootstrap new typescript library

```shell
chmod +x scripts/new.sh
scripts/new.sh --typescript $LIBRARY_NAME
cd typescript/$LIBRARY_NAME
```

##### Link and use typescript library in other packages

Go to library folder, then:

```shell
npm run mount
```

After that go to package, where linked library need and:

```shell
npm link $LIBRARY_NAME
```

Now you can use linked library

##### Build all changed typescript libs

```shell
chmod +x scripts/main.sh
scripts/main.sh typescript build $KEYSTORE_HOST $KEYSTORE_ACCESS_TOKEN
```

##### Build and publish all changed typescript libs

```shell
chmod +x scripts/main.sh
scripts/main.sh typescript publish $KEYSTORE_HOST $KEYSTORE_ACCESS_TOKEN
```

---

### Dart

##### Bootstrap new dart library

```shell
chmod +x scripts/helpers/new.sh
scripts/helpers/new.sh --dart $LIBRARY_NAME
cd dart/$LIBRARY_NAME
```

##### Build all changed dart libs

```shell
chmod +x scripts/main.sh
scripts/main.sh dart build $KEYSTORE_HOST $KEYSTORE_ACCESS_TOKEN
```

##### Build and publish all changed dart libs

```shell
chmod +x scripts/main.sh
scripts/main.sh dart publish $KEYSTORE_HOST $KEYSTORE_ACCESS_TOKEN
```

---

### Kotlin

##### Bootstrap new kotlin library

```shell
chmod +x scripts/helpers/new.sh
scripts/helpers/new.sh --android $LIBRARY_NAME # for android library
scripts/helpers/new.sh --jvm $LIBRARY_NAME # for jvm library
cd kotlin/$LIBRARY_NAME
```

##### Build all changed kotlin libs

```shell
chmod +x scripts/main.sh
scripts/main.sh kotlin build $KEYSTORE_HOST $KEYSTORE_ACCESS_TOKEN
```

##### Build and publish all changed kotlin libs

```shell
chmod +x scripts/main.sh
scripts/main.sh kotlin publish $KEYSTORE_HOST $KEYSTORE_ACCESS_TOKEN
```

---

### Test GitHub Actions workflow

Requirements:
- Docker
- Act utility
- secrets.env file with repository secrets

```shell
act --secret-file secrets.env
```
