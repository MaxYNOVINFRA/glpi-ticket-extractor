# Paramètres GLPI
$glpi_url = "http://192.168.80.151/glpi/apirest.php"
$app_token = "OskXTBNboqib2x1jM9tpSzf2DkRH5LST6JOZ1ZcI"
$user_token = "MkahiFOCZ6AHXmC9lMPySXZNayFfmCnuMpGOgoGW"
$exportPath = "C:\\CompteRendu\\tickets_glpi.csv"

# Dictionnaire Statut
$statuts = @{
    1 = "Nouveau"
    2 = "En cours"
    3 = "En attente"
    4 = "Résolu"
    5 = "Clos"
}

# Dictionnaire Priorité
$priorites = @{
    1 = "Très basse"
    2 = "Basse"
    3 = "Normale"
    4 = "Haute"
    5 = "Très haute"
}

# Fonction pour récupérer un nom depuis l'API GLPI
function Get-NameFromID($endpoint, $id) {
    if ($id -eq 0 -or $null -eq $id) { return "" }
    $url = "$glpi_url/$endpoint/$id"
    $result = Invoke-RestMethod -Uri $url -Method GET -Headers @{
        "App-Token" = $app_token
        "Session-Token" = $session_token
    }
    return $result.name
}

# Authentification GLPI
$auth = Invoke-RestMethod -Uri "$glpi_url/initSession" -Method GET -Headers @{
    "App-Token" = $app_token
    "Authorization" = "user_token $user_token"
}
$session_token = $auth.session_token
Write-Output "Authentification réussie."

# Récupération des tickets (Nouveau et En cours) + Description
$url_tickets = "$glpi_url/Ticket?criteria[0][field]=status&criteria[0][searchtype]=equals&criteria[0][value]=1&criteria[1][link]=OR&criteria[1][field]=status&criteria[1][searchtype]=equals&criteria[1][value]=2&forcedisplay[0]=id&forcedisplay[1]=name&forcedisplay[2]=status&forcedisplay[3]=date_mod&forcedisplay[4]=date_creation&forcedisplay[5]=priority&forcedisplay[6]=users_id_recipient&forcedisplay[7]=users_id_assign&forcedisplay[8]=itilcategories_id&forcedisplay[9]=content"

$response = Invoke-RestMethod -Uri $url_tickets -Method GET -Headers @{
    "App-Token" = $app_token
    "Session-Token" = $session_token
}

Write-Output "Tickets récupérés : $($response.Count)"

# Traitement des tickets
$tickets = foreach ($ticket in $response) {
    $demandeur = Get-NameFromID -endpoint "User" -id $ticket.users_id_recipient
    $attribueA = Get-NameFromID -endpoint "User" -id $ticket.users_id_assign
    $categorie = Get-NameFromID -endpoint "ITILCategory" -id $ticket.itilcategories_id

    [PSCustomObject]@{
        Titre                  = $ticket.name
        Description            = [System.Web.HttpUtility]::HtmlDecode($ticket.content)
        Statut                 = $statuts[$ticket.status]
        "Dernière modification"= $ticket.date_mod
        "Date d'ouverture"     = $ticket.date_creation
        Priorité               = $priorites[$ticket.priority]
        Demandeur              = $demandeur
        "Attribué à"           = $attribueA
        Catégorie              = $categorie
    }
}

# Vérifier si le dossier existe
if (-not (Test-Path -Path (Split-Path $exportPath))) {
    New-Item -ItemType Directory -Path (Split-Path $exportPath) | Out-Null
}

# Export en CSV
$tickets | Export-Csv -Path $exportPath -NoTypeInformation -Delimiter ";"

Write-Output "Export terminé : $exportPath"

# Fermer la session API GLPI
Invoke-RestMethod -Uri "$glpi_url/killSession" -Method GET -Headers @{
    "App-Token" = $app_token
    "Session-Token" = $session_token
}

Write-Output "Session GLPI fermée."
