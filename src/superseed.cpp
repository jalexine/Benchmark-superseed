#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <filesystem>

std::vector<std::pair<std::string, std::string>> parseFasta(const std::string& fastaPath) {
    std::vector<std::pair<std::string, std::string>> sequences;
    std::ifstream file(fastaPath);
    std::string line, id, sequence;

    while (std::getline(file, line)) {
        if (line[0] == '>') {
            if (!id.empty()) sequences.emplace_back(id, sequence);
            id = line.substr(1);
            sequence.clear();
        } else {
            sequence += line;
        }
    }
    if (!id.empty()) sequences.emplace_back(id, sequence);
    return sequences;
}

std::vector<std::string> toseed(const std::string& seq, int n) {
    std::vector<std::string> result(n);
    for (size_t i = 0; i < seq.size(); ++i) {
        result[i % n] += seq[i];
    }
    return result;
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "♡ Usage: ./superseed <fasta_path> <n>" << std::endl;
        return 1;
    }

    std::string fastaPath = argv[1];
    int n = std::stoi(argv[2]);
    auto sequences = parseFasta(fastaPath);

    std::filesystem::create_directories("data");
    std::ofstream outputFile("data/output_N" + std::to_string(n) + ".fa");

    for (const auto& [seqid, seq] : sequences) {
        auto seeds = toseed(seq, n);
        for (size_t x = 0; x < seeds.size(); ++x) {
            outputFile << ">" << seqid << "_part" << x + 1 << "\n" << seeds[x] << "\n";
        }
    }

    return 0;
}

