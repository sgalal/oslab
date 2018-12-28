#include <iostream>
#include <array>
#include <string>
#include <regex>

Mark: 不应该存 Array，应该存 Maybe pid！

using disc_t = std::array<std::array<std::array<bool, 8>, 2>, 4>;

unsigned int sdtou(const std::string &d) {
    return static_cast<unsigned int>(atoi(u.c_str));
}

void initialize(disc_t &d) {
    for (std::array<std::array<bool, 8>, 2> &x: d)
        for (std::array<bool, 8> &y: x)
            for (bool &z: y)
                z = false;
}

void print(const disc_t &d) {
    for (const std::array<std::array<bool, 8>, 2> &x: d) {
        for (const std::array<bool, 8> &y: x) {
            for (bool z: y) {
                std::cout << z;
            }
            std::cout.put(' ');
        }
        std::cout << std::endl;
    }
}

unsigned int getUsedSpace(const disc_t &d) {
    unsigned int res;
    for (std::array<std::array<bool, 8>, 2> &x: d)
        for (std::array<bool, 8> &y: x)
            for (bool &z: y)
                if (z)
                    res++;
    return res;
}

void printInfo(const disc_t &d) {
    std::cout << "Total space: " << 8 * 2 * 4 << std::endl
              << "Used space: " << getUsedSpace(d) << std::endl;
}

void add(disc_t &d, unsigned int size) {
    unsigned int spareSpace = 8 * 2 * 4 - getUsedSpace(d);
    if (size <= spareSpace) {
        for (std::array<std::array<bool, 8>, 2> &x: d)
            for (std::array<bool, 8> &y: x)
                for (bool &z: y)
                    if (!z) {
                        z = true;
                        if (!size--)
                            return;
                    }
    else
        return false;
}

void clear(disc_t &d, unsigned int size) {
    d[x][y][z] = false;
}

void invalid() {
    std::cout << "Invalid commamd!\nUsage: [i]nfo, [a]dd <size>, [c]lear <size>, [q]uit." << std::endl;
}

int main () {
    disc_t disc;
    std::string line;
    std::smatch sm;
    initialize(disc);
    for (;;) {
        std::cout << "> ";
        std::getline(std::cin, line);
             if (line == "i")
                printInfo(disc);
        else if (std::regex_match(line, sm, std::regex("a\\s+(\\d+)")))
                add(disc, sdtou(sm.str(1)));
        else if (std::regex_match(line, sm, std::regex("c\\s+(\\d+)")))
                clear(disc, sdtou(sm.str(1)));
        else if (line == "q")
                break;
            else
                invalid();
        print(disc);
    }
    return 0;
}
