const express = require("express");
const express_ws = require("express-ws");
const e = require("express");
const uuidv4 = require('uuid').v4;

var app = express();
express_ws(app);

app.use(express.static('static'));

var connections = []
var start_id = null

app.ws('/api', (ws, req) => {
    if (connections.length > 4 || start_id != null) return;

    var id = uuidv4();

    connections.push({ws, id});

    ws.send(JSON.stringify({
        type: "id",
        id
    }));

    connections.filter(conn =>
        conn.ws != ws
    ).forEach(conn => {
        conn.ws.send(JSON.stringify({
            "type": "player_join"
        }));
    });

    ws.on('message', msg => {
        var parse = JSON.parse(msg);

        if (parse.type == "button" || parse.type == "unbutton") {
            connections.forEach(conn => {
                conn.ws.send(msg);
            });
        } else if (parse.type == "get_peers") {
            ws.send(JSON.stringify({
                "type": "got_peers",
                "peers": connections.filter(conn =>
                    conn.ws != ws
                ).map(conn =>
                    conn.id
                )
            }));
        } else if (parse.type == "start_game") {
            start_id = parse.id;
        }
    });

    ws.on('close', () => {
        var id = null
        connections = connections.filter(conn => {
            if (conn.ws == ws) {
                id = conn.id;

                if (start_id == conn.id) {
                    start_id = null;
                }
                return false;
            }
            return true;
        });
        connections.map(conn =>
            conn.ws
        ).forEach(conn => {
            conn.send(JSON.stringify({
                "type": "leave",
                "id": id
            }));
        });
    });
});

app.listen(8080);