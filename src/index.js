import './main.css';
import { Main } from './Main.elm';

// var app = Main.embed(document.getElementById('root'));
var app = Main.fullscreen();
var offset = -1 * (new Date()).getTimezoneOffset() * 60 * 1000;

app.ports.fetchOffset.subscribe(function(_) {
    app.ports.acceptOffset.send(offset);
});

app.ports.fetchPermission.subscribe(function(_) {
    if (window.Notification) {
        app.ports.acceptPermission.send(Notification.permission);
    } else {
        app.ports.acceptPermission.send("unsupported");
    }
});

app.ports.requestPermission.subscribe(function(_) {
    Notification.requestPermission(function (permission) {
        app.ports.acceptPermission.send(permission);
    });
});

app.ports.notify_.subscribe(function(opt) {
    new Notification(opt.title, opt);
})