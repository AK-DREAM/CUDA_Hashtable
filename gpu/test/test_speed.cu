#include "reader.h"
#include "../dinner123.h"
#include "cpu.h"
#include <bits/stdc++.h>
using namespace std;
typedef unsigned long long uint64;
template <typename T>
double CPU_PERF(T func) {
	auto t0 = chrono::high_resolution_clock::now();
	func();
	auto t1 = chrono::high_resolution_clock::now();
	double duration = chrono::duration<double>(t1 - t0).count();
	return duration;
}
CPUHashTable<ull, float, 8> cpuhstb;
template <typename T>
double GPU_PERF(T func) {
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start);
	func();
	cudaEventRecord(stop);
	cudaError_t err = cudaStreamSynchronize(0);
	if (err != cudaSuccess) {
		cerr << "PERF_DEV run failed.\n";
		exit(0);
	}
	float duration = 0;
	cudaEventElapsedTime(&duration, start, stop);
	return duration / 1000;
}
int main() {
	system("./gen");
	cerr << "Finish generating\n";
	data_loader insertion("input1");
	file_loader<uint64> finding("input2.keys");
	dinner123 Hashtable;
	int n = insertion.size();
	int a[5] = {0, 0.1*n, 0.2*n, 0.5*n, n};
	double alpha[5] = {0, 0.28, 0.24, 0.18, 0.1};
	double beta[5] = {0, 0.42, 0.56, 0.72, 0.9};
	cerr << insertion.size() * insertion.dim() * sizeof(uint64) << '\n';
	uint64 *answer_cpu = (uint64 *)malloc(insertion.size() * insertion.dim() * sizeof(uint64)), *answer_gpu = (uint64 *)malloc(insertion.size() * insertion.dim() * sizeof(uint64));
	bool *exist_cpu = (bool *)malloc(insertion.size()), *exist_gpu = (bool *)malloc(insertion.size());
	double cpu_total_score = 0, gpu_total_score = 0;
	// cerr << "CPU PERF-----------------------------------------\n";
	// for (int i = 1; i <= 4; ++i) {
	// 	if (a[i] == a[i - 1])
	// 		continue;
	// 	double cpu_insert_time = CPU_PERF([&] { cpuhstb.insert(a[i] - a[i - 1], insertion.keys() + a[i - 1], insertion.vals() + a[i - 1] * insertion.dim()); });
	// 	double cpu_insert_qps = (a[i] - a[i - 1]) / cpu_insert_time;
	// 	double cpu_find_time = CPU_PERF([&] { cpuhstb.find(a[i] - a[i - 1], finding.data() + a[i - 1], answer_cpu + a[i - 1] * insertion.dim(), exist_cpu + a[i - 1]); });
	// 	double cpu_find_qps = (a[i] - a[i - 1]) / cpu_find_time;
	// 	int rate = a[i] * 100. / n + 0.5;
	// 	double score = (alpha[i] * cpu_find_qps + beta[i] * cpu_insert_qps) * (1 - exp(-exp(1)));
	// 	cpu_total_score += score;
	// 	cerr << "Finishing " << rate << "%, score=" << score << ", insert_qps=" << cpu_insert_qps << ", find_qps=" << cpu_find_qps << "\n";
	// }
	cerr << "GPU PERF-----------------------------------------\n";
	for (int i = 1; i <= 4; ++i) {
		if (a[i] == a[i - 1])
			continue;
		double gpu_insert_time = GPU_PERF([&] { Hashtable.insert(a[i] - a[i - 1], insertion.keys() + a[i - 1], (unsigned long long)(insertion.vals() + a[i - 1] * insertion.dim())); });
		double gpu_insert_qps = (a[i] - a[i - 1]) / gpu_insert_time;
		double gpu_find_time = GPU_PERF([&] { Hashtable.query(a[i] - a[i - 1], finding.data() + a[i - 1], answer_gpu + a[i - 1] * insertion.dim(), exist_gpu + a[i - 1]); });
		double gpu_find_qps = (a[i] - a[i - 1]) / gpu_find_time;
		int cnt = 0;
		for (int j = a[i - 1]; j < a[i]; ++j) {
			if (exist_cpu[j] == exist_gpu[j]) {
				cnt += answer_cpu[j] == answer_gpu[j] || !exist_cpu[j];
			} else
				cerr << "zzh\n";
		}
		double accuracy = 1.0 * cnt / (a[i] - a[i - 1]);
		int rate = a[i] * 100. / n + 0.5;
		double score = (alpha[i] * gpu_find_qps + beta[i] * gpu_insert_qps) * (1 - exp(-exp(1) * accuracy));
		gpu_total_score += score;
		cerr << "Finishing " << rate << "%, score=" << score << ", insert_qps=" << gpu_insert_qps << ", find_qps=" << gpu_find_qps << " ,accuracy=" << accuracy << " (" << cnt << "/" << a[i] - a[i - 1]
			 << ")\n";
	}
	cerr << "CPU Total Score: " << cpu_total_score << '\n';
	cerr << "GPU Total Score: " << gpu_total_score << '\n';
	return 0;
}