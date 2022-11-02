<?php
$servername = "";
$username = "root";
$password = "semsenha2022";
$database = "diodb";

// Criar conexão


$link = new mysqli($servername, $username, $password, $database);


/* check connection */
if (mysqli_connect_errno()) {
    printf("Connect failed: %s\n", mysqli_connect_error());
    exit();
} else {
    echo "Conectado com sucesso";
}

?>
