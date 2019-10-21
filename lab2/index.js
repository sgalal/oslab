'use strict';

var cnt, totalSpace, xs;

window.onload = initialize;

function showRect(leftPercent, thisPercent, isIdle, str) {
    var canvas = document.getElementById('canvas');
    var ctx = canvas.getContext('2d');

    ctx.beginPath();
    ctx.fillStyle = isIdle ? 'white' : 'aliceblue';
    ctx.strokeStyle = 'purple';
    ctx.rect(canvas.width * leftPercent, 0, canvas.width * thisPercent, canvas.height);
    ctx.fill();
    ctx.stroke();
    ctx.closePath();

    ctx.beginPath();
    ctx.fillStyle = 'black';
    ctx.fillText(str, canvas.width * (leftPercent + thisPercent * 0.5), canvas.height * 0.5);
    ctx.closePath();
}

function initialize() {
    var canvas = document.getElementById('canvas');
    var ctx = canvas.getContext('2d');
    ctx.canvas.width = canvas.width = canvas.offsetWidth;
    ctx.canvas.height = canvas.height = canvas.offsetHeight;

    ctx.font = '110% sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    cnt = 1;

    totalSpace = parseInt(document.getElementById('input_total_space').value);
    xs = PS.Main.initialize(totalSpace);
    xsDraw();
}

function allocate() {
    var ret = PS.Main.allocate(cnt)(parseInt(document.getElementById('input_allocate').value))(xs);
    if (ret) {
        cnt++;
        p_warn.innerText = '';
        xs = ret;
        xsDraw();
    } else {
        p_warn.innerText = 'You cannot do that!';
    }
    document.getElementById('input_allocate').value = '';
}

function retrieve() {
    var ret = PS.Main.retrieve(parseInt(document.getElementById('input_pid').value))(xs);
    if (ret) {
        p_warn.innerText = '';
        xs = ret;
        xsDraw();
    } else {
        p_warn.innerText = 'You cannot do that!';
    }
    document.getElementById('input_pid').value = '';
}

function xsDraw() {
    var acc = 0;
    for (var i = 0; i < xs.length; i++) {
        var pid = xs[i].value0.pid;
        var len = xs[i].value0.len;
        if (pid) {
            showRect(acc, len / totalSpace, true, len + '(' + pid + ')');
        } else {
            showRect(acc, len / totalSpace, false, len);
        }
        acc += xs[i].value0.len / totalSpace;
    }
}
