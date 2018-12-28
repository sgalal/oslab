#include <iostream>
#include <array>
#include <string>
#include <regex>

using disc_t = std::array<std::array<std::array<bool, 8>, 2>, 4>;

static unsigned int sdtou(const std::string &d) {
    return static_cast<unsigned int>(atoi(d.c_str()));
}

static void initialize(disc_t &d) {
    for (std::array<std::array<bool, 8>, 2> &x: d)
        for (std::array<bool, 8> &y: x)
            for (bool &z: y)
                z = false;
}

static void print(const disc_t &d) {
    for (const std::array<std::array<bool, 8>, 2> &x: d) {
        for (const std::array<bool, 8> &y: x) {
            for (const bool &z: y) {
                std::cout << z;
            }
            std::cout.put(' ');
        }
        std::cout << std::endl;
    }
}

static unsigned int getUsedSpace(const disc_t &d) {
    unsigned int res = 0;
    for (const std::array<std::array<bool, 8>, 2> &x: d)
        for (const std::array<bool, 8> &y: x)
            for (const bool &z: y)
                if (z)
                    res++;
    return res;
}

static void printInfo(const disc_t &d) {
    std::cout << "Total space: " << 8 * 2 * 4 << std::endl
              << "Used space: " << getUsedSpace(d) << std::endl;
}

static bool add(disc_t &d, unsigned int size) {
    unsigned int spareSpace = 8 * 2 * 4 - getUsedSpace(d);
    if (size <= spareSpace) {
        for (std::array<std::array<bool, 8>, 2> &x: d)
            for (std::array<bool, 8> &y: x)
                for (bool &z: y)
                    if (!z) {
                        z = true;
                        if (!--size)
                            return true;
                    }
    }
    return false;
}

static void clear(disc_t &d, unsigned int x, unsigned int y, unsigned int z) {
    d[x][y][z] = false;
}

static void invalid() {
    std::cout << "Invalid commamd!\nUsage: [i]nfo, [a]dd <size>, [c]lear [0-7] [0-1] [0-3], [q]uit." << std::endl;
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
        else if (std::regex_match(line, sm, std::regex("c\\s+([0-7])\\s+([0-1])\\s+([0-3])")))
                clear(disc, sdtou(sm.str(1)), sdtou(sm.str(2)), sdtou(sm.str(3)));
        else if (line == "q")
                break;
            else
                invalid();
        print(disc);
    }
    return 0;
}
