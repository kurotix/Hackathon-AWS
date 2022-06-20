# AWS S3 static website bucket

Ce module provisionne un bucket S3 configuré pour l'hébergement d'un site web statique.

## Usage

```hcl
module "<module name>" {
    source = "path of your module"
    bucket_name = "<UNIQ BUCKET NAME>"
    tags = {
        key   = "<value>"
    }
}
```
Lorsque votre bucket est créé, envoyer un fichier `index.html` et un fichier `error.html` dans votre bucket. 