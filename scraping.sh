#!/bin/bash

# Configuration des variables
URL_SITE="https://readi.fi/sitemap.xml"
DB_TYPE="sqlite"  # Peut être "sqlite" ou "postgres"
DB_NAME="liste_URL"
TABLE_NAME="assets"
ASSET_PREFIX="https://readi.fi/asset"

# Création de la base de données et de la table
if [ "$DB_TYPE" = "sqlite" ]; then
    sqlite3 "$DB_NAME.db" "CREATE TABLE IF NOT EXISTS $TABLE_NAME (id INTEGER PRIMARY KEY, url TEXT, title TEXT, description TEXT);"
    echo "Table créée dans SQLite."
elif [ "$DB_TYPE" = "postgres" ]; then
    psql -d "$DB_NAME" -c "CREATE TABLE IF NOT EXISTS $TABLE_NAME (id SERIAL PRIMARY KEY, url TEXT, title TEXT, description TEXT);"
    echo "Table créée dans PostgreSQL."
fi

# Téléchargement du sitemap
curl -s "$URL_SITE" -o sitemap.xml

# Extraction des URLs spécifiques
xmllint --xpath "//url/loc/text()" sitemap.xml | grep "^$ASSET_PREFIX" > asset_urls.txt

# Comptage des URLs
url_count=$(wc -l < asset_urls.txt)
echo "Nombre d'URLs trouvées: $url_count"

# Boucle sur chaque URL pour scraper les données et insérer dans la base de données
while IFS= read -r 
url; do
    page_content=$(curl -s "$url")
    
    # Extraction du title et de la description
    title=$(echo "$page_content" | sed -n 's:.*<title>\(.*\)</title>.*:\1:p')
    description=$(echo "$page_content" | sed -n 's/.*<meta name="description" content="\([^"]*\)".*/\1/p')
    
    # Échappement des apostrophes dans les variables pour éviter les erreurs SQL
    url_escaped=$(echo "$url" | sed "s/'/''/g")
    title_escaped=$(echo "$title" | sed "s/'/''/g")
    description_escaped=$(echo "$description" | sed "s/'/''/g")
    
    # Insertion dans la base de données en fonction du type de DB
    if [ "$DB_TYPE" = "sqlite" ]; then
        sqlite3 "$DB_NAME.db" "INSERT INTO $TABLE_NAME (url, title, description) VALUES ('$url_escaped', '$title_escaped', '$description_escaped');"
    elif [ "$DB_TYPE" = "postgres" ]; then
        psql -d "$DB_NAME" -c "INSERT INTO $TABLE_NAME (url, title, description) VALUES ('$url_escaped', '$title_escaped', '$description_escaped');"
    fi

    echo "Données insérées pour l'URL: $url"
done < asset_urls.txt

echo "Scraping et insertion terminés."

# Nettoyage des fichiers temporaires
rm sitemap.xml asset_urls.txt

# Au lieu d'échapper les apostrophes, on peut (comme vous l'avez fait en python), passer les variables en arguments
# "INSERT INTO $TABLE_NAME (url, title, description) VALUES (?, ?, ?);" "$url" "$title" "$description"

# Cela évite au passage de signaler une injection SQL si le titre de la page est par exemple "L'année de WESTERN UNION"
# On se retrouverait avec des "SQL injection detected" dans les logs etc.
