// Importa el módulo http
const { stat } = require("fs");
const http = require("http");

require('dotenv').config();


const port = process.env.PORT || 8080;
const hash = process.env.HASH || "";

let _cmd = process.env.CMD.split(" ");
let cmd = _cmd.shift();

// Crea un servidor HTTP
const server = http.createServer((req, res) => {
    console.log("Request received", req.url );

    if ( hash == "" ){
        res.statusCode = 403;
        res.end("Hash not defined");
        return ;
    }

    if ( hash.length < 50 ){
        res.statusCode = 403;
        res.end("Hash too small");
        return ;
    }


    if ( req.url != `/${hash}` ) {
        res.statusCode = 404;
        res.end("Page not found");
        return ;
    }

    
    const child_process = require('child_process');
    let out;

    out = child_process.spawnSync(cmd, _cmd);
    console.log(out.stdout.toString());

    // Envia una respuesta HTTP 200
    res.statusCode = 200;
    
    // Establece el tipo de contenido
    res.setHeader("Content-type", "text/html");
    console.log("HOLA MUNDO", new Date());
    // Envia el cuerpo de la respuesta
    res.end("<html><body><h1>Hola, mundo!</h1></body></html>");
    return ;
    
    
});

console.log("Starting server", port);
// Escucha peticiones en el puerto 8080
server.listen(port);