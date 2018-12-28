var cnt, totalSpace, xs;

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

    ctx.font = '120% sans-serif';
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";

    cnt = 0;

    totalSpace = parseInt(document.getElementById("input_total_space").value);
    xs = PS.Main.initialize(totalSpace);
    resShow(xs);
}

function allocate() {
    var ret = PS.Main.allocate(++cnt)(parseInt(document.getElementById("input_allocate").value))(xs);
    if (ret.constructor.name == "Just") {
        document.getElementById("p_prom").innerText = "";
        xs = ret.value0;
        resShow(xs);
    } else {
        document.getElementById("p_prom").innerText = "You cannot do that!";
    }
}

function retrieve() {
    var ret = PS.Main.retrieve(parseInt(document.getElementById("input_pid").value))(xs);
    if (ret.constructor.name == "Just") {
        document.getElementById("p_prom").innerText = "";
        xs = ret.value0;
        resShow(xs);
    } else {
        document.getElementById("p_prom").innerText = "You cannot do that!";
    }
}

function resShow(arr) {
    var acc = 0;
    for (var i = 0; i < arr.length; i++) {
        var pid = arr[i].value0.pid;
        if (pid) {
            showRect(acc, arr[i].value0.len / totalSpace, true, arr[i].value0.len + "[" + pid + "]");
        } else {
            showRect(acc, arr[i].value0.len / totalSpace, false, arr[i].value0.len);
        }
        acc += arr[i].value0.len / totalSpace;
    }
}
