"use strict";

var list;

var Module = {
    onRuntimeInitialized: function() {
        list = new Module.PCBList();
        visualize();
    }
};

function writeRList() {
    var tableStr = "<h2>Running List</h2><table><tr>"
    + "<th>Pname</th>"
    + "<th>Pid</th>"
    + "<th>Time Needed</th>"
    + "<th>Time Remain</th>"
    + "</tr>";
    var innerList = list.getRList();
    if (!innerList.empty()) {
        var size = list.getRListSize();
        var listIter = list.getRListCur();
        do {
            tableStr += "<tr>"
                + "<td>" + Module.iterNext(listIter).get().getPname() + "</td>"
                + "<td>" + Module.iterNext(listIter).get().getPid() + "</td>"
                + "<td>" + Module.iterNext(listIter).get().getTimeNeeded() + "</td>"
                + "<td>" + Module.iterNext(listIter).get().getTimeRemain() + "</td>"
                + "</tr>";
            listIter = Module.iterEqual(Module.iterNext(Module.iterNext(listIter)), innerList.cend()) ? innerList.cbefore_begin() : Module.iterNext(listIter);
        } while (!Module.iterEqual(listIter, list.getRListCur()) && --size);
        // Actually it should be OK with the first check only, but it unexpectedly return true at all time and caused an infinite loop, so I added the size check
    }
    tableStr += "</table>";
    document.getElementById("span_rList").innerHTML = tableStr;
}

function writeEList() {
    var tableStr = "<h2>Ending List</h2><table><tr>"
    + "<th>Pname</th>"
    + "<th>Pid</th>"
    + "<th>Time Needed</th>"
    + "<th>Time Remain</th>"
    + "</tr>";
    var innerList = list.getEList();
    var listIter = innerList.cbegin();
    while (!Module.iterEqual(listIter, innerList.cend())) {
        tableStr += "<tr>"
            + "<td>" + listIter.get().getPname() + "</td>"
            + "<td>" + listIter.get().getPid() + "</td>"
            + "<td>" + listIter.get().getTimeNeeded() + "</td>"
            + "<td>" + listIter.get().getTimeRemain() + "</td>"
            + "</tr>";
        listIter = Module.iterNext(listIter);
    }
    tableStr += "</table>";
    document.getElementById("span_eList").innerHTML = tableStr;
}

function visualize() {
    writeRList();
    writeEList();
}

function but_add() {
    list.append(document.getElementById("input_pname").value, parseInt(document.getElementById("input_timeNeeded").value));
    visualize();
}

function but_kill() {
    list.kill(parseInt(document.getElementById("input_pid").value));
    visualize();
}

function but_run() {
    list.run();
    visualize();
}
