# Installa Otto in Claude Code, su Windows.
#   irm https://raw.githubusercontent.com/LTVBEAT/otto-claude/main/installa.ps1 | iex
#
# Gli stessi passi di installa.sh (Mac), più la pulizia di un catalogo scaricato a metà: su Windows
# il primo «marketplace add» può fallire con EPERM sul rinomina della cartella e lasciare un catalogo
# vuoto («Plugin otto not found»). Tutto dentro una funzione e con «return», mai «exit»: lanciato con
# iex, un exit chiuderebbe la finestra di PowerShell.

function Installa-Otto {
    $Indirizzo = "https://otto-hermes.ltvalue.it/mcp"
    $Minima = [version]"2.1.147"
    $Cartella = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE ".claude" }

    Write-Host ""
    Write-Host "  Otto per Claude Code"
    Write-Host "  --------------------"

    if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Host "  Non trovo Claude Code su questo PC. Installalo da https://claude.com/code e rilancia."
        return
    }
    $Testo = (& claude --version 2>$null) -join " "
    if ($Testo -notmatch '(\d+\.\d+\.\d+)' -or [version]$Matches[1] -lt $Minima) {
        Write-Host "  Claude Code $Testo e' troppo vecchio. Scrivi  claude update  e rilancia."
        return
    }

    Write-Host "  1/4  Aggiungo il catalogo dei plugin LTV e installo il plugin otto"
    if (-not (Installa-Plugin)) {
        Write-Host "       Primo tentativo non riuscito: pulisco il catalogo e riprovo."
        & claude plugin marketplace remove ltvbeat *> $null
        $Cataloghi = Join-Path $Cartella "plugins\marketplaces"
        Get-ChildItem -Path $Cataloghi -Filter "LTVBEAT-otto-claude*" -Directory -ErrorAction SilentlyContinue |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        # L'antivirus puo' tenere bloccati i file appena scaricati per qualche secondo.
        Start-Sleep -Seconds 5
        if (-not (Installa-Plugin)) {
            Write-Host "  Installazione non riuscita. Manda a Max uno screenshot di questa finestra."
            return
        }
    }
    # Se c'era gia', lo porta all'ultima versione.
    & claude plugin update otto@ltvbeat *> $null

    Write-Host "  2/4  Attivo gli aggiornamenti automatici di Otto"
    if (-not (Accendi-Aggiornamenti (Join-Path $Cartella "settings.json"))) {
        Write-Host "       Non ci sono riuscito. Fallo a mano in Claude Code: /plugin, scheda Marketplaces,"
        Write-Host "       ltvbeat, Enable auto-update."
    }

    Write-Host "  3/4  Incolla il tuo token di Otto (te lo da' Max) e premi Invio."
    Write-Host "       Mentre incolli vedi solo asterischi: e' normale."
    $Segreto = Read-Host "       Token" -AsSecureString
    $Token = ([Net.NetworkCredential]::new("", $Segreto).Password).Trim()
    if (-not $Token) {
        Write-Host "  Nessun token inserito. Rilancia il comando quando ce l'hai."
        return
    }

    Write-Host "  4/4  Controllo il token e lo salvo"
    $Codice = Prova-Token $Indirizzo $Token
    if ($Codice -eq 401) {
        Write-Host "  Il token non e' valido: controlla di averlo copiato tutto, oppure chiedine uno nuovo a Max."
        return
    }
    ('{"token":"' + $Token + '"}') | & claude plugin configure otto@ltvbeat --values-stdin *> $null
    $Esito = $LASTEXITCODE
    $Token = $null
    $Segreto = $null
    if ($Esito -ne 0) {
        Write-Host "  Non sono riuscito a salvare il token. Avvisa Max."
        return
    }

    Write-Host ""
    if ($Codice -eq 0) {
        Write-Host "  Token salvato, ma adesso Otto non risponde (rete?). Riprova piu' tardi da Claude Code."
    } else {
        Write-Host "  Fatto! Il token e' salvato."
    }
    Write-Host ""
    Write-Host "  Chiudi e riapri Claude Code, poi scrivi:"
    Write-Host "     chiedi a Otto come vanno gli account di TKART questa settimana"
    Write-Host ""
}

function Installa-Plugin {
    & claude plugin marketplace add LTVBEAT/otto-claude *> $null
    if ($LASTEXITCODE -ne 0) { & claude plugin marketplace update ltvbeat *> $null }
    & claude plugin install otto@ltvbeat *> $null
    if ($LASTEXITCODE -eq 0) { return $true }
    # «Gia' installato» non e' un errore.
    return [bool]((& claude plugin list 2>$null) -match "otto@ltvbeat")
}

# Il catalogo LTV non e' di Anthropic, quindi parte senza aggiornamenti automatici e la CLI non ha
# un'opzione per accenderli: si scrive autoUpdate sulla voce del catalogo nelle impostazioni, dopo
# una copia. Un file che non si legge non si tocca.
function Accendi-Aggiornamenti([string]$File) {
    try {
        $Impostazioni = [pscustomobject]@{}
        if (Test-Path $File) {
            $Grezzo = [IO.File]::ReadAllText($File)
            if ($Grezzo.Trim()) { $Impostazioni = $Grezzo | ConvertFrom-Json -ErrorAction Stop }
            Copy-Item $File "$File.bak-otto" -Force
        }
        if (-not $Impostazioni.PSObject.Properties["extraKnownMarketplaces"]) {
            $Impostazioni | Add-Member -NotePropertyName extraKnownMarketplaces -NotePropertyValue ([pscustomobject]@{})
        }
        $Cataloghi = $Impostazioni.extraKnownMarketplaces
        if (-not $Cataloghi.PSObject.Properties["ltvbeat"]) {
            $Voce = [pscustomobject]@{ source = [pscustomobject]@{ source = "github"; repo = "LTVBEAT/otto-claude" } }
            $Cataloghi | Add-Member -NotePropertyName ltvbeat -NotePropertyValue $Voce
        }
        $Cataloghi.ltvbeat | Add-Member -NotePropertyName autoUpdate -NotePropertyValue $true -Force
        $Json = $Impostazioni | ConvertTo-Json -Depth 64
        # UTF-8 senza BOM: Windows PowerShell 5.1 con Set-Content -Encoding UTF8 metterebbe il BOM.
        [IO.File]::WriteAllText($File, $Json + "`n", (New-Object Text.UTF8Encoding $false))
        return $true
    } catch {
        return $false
    }
}

# 401 = token sbagliato; 0 = server irraggiungibile; qualunque altra risposta = il token passa.
function Prova-Token([string]$Indirizzo, [string]$Token) {
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}
    try {
        $Risposta = Invoke-WebRequest -Uri $Indirizzo -Method Post -Body "{}" -ContentType "application/json" `
            -Headers @{ Authorization = "Bearer $Token" } -UseBasicParsing -TimeoutSec 15
        return [int]$Risposta.StatusCode
    } catch {
        $Errore = $_.Exception
        if ($Errore.Response) { return [int]$Errore.Response.StatusCode }
        return 0
    }
}

Installa-Otto
