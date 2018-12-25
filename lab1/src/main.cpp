#include <algorithm>
#include <emscripten/bind.h>
#include <forward_list>
#include <iterator>
#include <string>

using namespace emscripten;

class PCBList {
public:
    using pid_t = unsigned int;
    class PCB {
        const std::string pname;
        const pid_t pid;
        const unsigned int timeNeeded;
        unsigned int timeRemain;

    public:
        unsigned int run() { return --timeRemain; }
        const std::string &getPname() const { return pname; }
        pid_t getPid() const { return pid; }
        unsigned int getTimeNeeded() const { return timeNeeded; }
        unsigned int getTimeRemain() const { return timeRemain; }
        PCB(std::string pname, pid_t pid, unsigned int timeNeeded)
            : pname(pname), pid(pid), timeNeeded(timeNeeded), timeRemain(timeNeeded) {}
    };
    class UniqueId {
        pid_t data;

    public:
        UniqueId() : data(1) {}
        pid_t operator()() { return data++; }
    };

private:
    PCBList::UniqueId uid;
    std::forward_list<PCBList::PCB> rList;              // The timeRemain in this list must always greater that 0
    std::forward_list<PCBList::PCB> eList;              // The timeRemain in this list must always equal to 0
    std::forward_list<PCBList::PCB>::iterator rListCur; // Despite empty list, std::next(rListCur) must always be valid
public:
    PCBList() : rListCur(rList.before_begin()) {}
    pid_t append(std::string pname, unsigned int timeNeeded) {
        const pid_t pid = uid();
        if (!timeNeeded)
            eList.emplace_after(eList.before_begin(), PCB{pname, pid, timeNeeded});
        else
            rList.emplace_after(rListCur, PCB{pname, pid, timeNeeded});
        return pid;
    }
    void kill(pid_t pid) {
        std::forward_list<PCB>::iterator it = std::adjacent_find(
            rList.before_begin(), rList.end(), [pid](const PCB &, const PCB &p) { return p.getPid() == pid; });
        if (it != rList.end())
            eList.splice_after(eList.before_begin(), rList, it);
    }
    bool run() {
        if (rList.empty()) {
            return false;
        } else {
            if (!(std::next(rListCur)->run())) {
                eList.splice_after(eList.before_begin(), rList, rListCur);
                rListCur = std::next(rListCur) == rList.end() || std::next(std::next(rListCur)) == rList.end()
                               ? rList.before_begin()
                               : std::next(rListCur);
            } else {
                rListCur = std::next(std::next(rListCur)) == rList.end() ? rList.before_begin() : std::next(rListCur);
            }
            return true;
        }
    }
    const std::forward_list<PCBList::PCB> &getRList() const { return rList; }
    const std::forward_list<PCBList::PCB> &getEList() const { return eList; }
    std::forward_list<PCBList::PCB>::const_iterator getRListCur() const { return rListCur; }
    unsigned int getRListSize() const { return std::distance(rList.cbegin(), rList.cend()); }
};

std::forward_list<PCBList::PCB>::const_iterator iterNext(std::forward_list<PCBList::PCB>::const_iterator cit) {
    return std::next(cit);
}

bool iterEqual(std::forward_list<PCBList::PCB>::const_iterator ita,
               std::forward_list<PCBList::PCB>::const_iterator itb) {
    return ita == itb;
}

EMSCRIPTEN_BINDINGS(my_bindings) {
    class_<PCBList>("PCBList")
        .constructor<>()
        .function("append", &PCBList::append)
        .function("kill", &PCBList::kill)
        .function("run", &PCBList::run)
        .function("getRList", &PCBList::getRList)
        .function("getEList", &PCBList::getEList)
        .function("getRListCur", &PCBList::getRListCur)
        .function("getRListSize", &PCBList::getRListSize);
    class_<std::forward_list<PCBList::PCB>>("fowardList")
        .function("empty", &std::forward_list<PCBList::PCB>::empty)
        .function("cbefore_begin", &std::forward_list<PCBList::PCB>::cbefore_begin)
        .function("cbegin", &std::forward_list<PCBList::PCB>::cbegin)
        .function("cend", &std::forward_list<PCBList::PCB>::cend);
    class_<std::forward_list<PCBList::PCB>::const_iterator>("fowardListConstIterator")
        .function("get", &std::forward_list<PCBList::PCB>::const_iterator::operator*);
    class_<PCBList::PCB>("PCB")
        .function("getPname", &PCBList::PCB::getPname)
        .function("getPid", &PCBList::PCB::getPid)
        .function("getTimeNeeded", &PCBList::PCB::getTimeNeeded)
        .function("getTimeRemain", &PCBList::PCB::getTimeRemain);
    function("iterNext", &iterNext);
    function("iterEqual", &iterEqual);
}
