const http = require('http');

const hostname = '0.0.0.0';
const [ port = 8080 ] = process.argv.slice( process.argv.indexOf( '--port' ) + 1 );


const server = http.createServer(( req, res )=>{
    res.end( 'Hello World!\n' );
});

server.listen( port, hostname, ( err )=>{
    if( typeof err !== 'undefined' && err !== null ){
        console.error( err );
        process.exitCode = 1
    }

    console.log( `http server listening on ${ port }` );
});

process.on( 'SIGTERM', ()=>{
    server.close( ()=>{
        console.log( 'shutting down server' );
        process.exitCode = 0
    });
});
