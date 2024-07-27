#include <bits/stdc++.h>
using namespace std;


template <typename K, typename V, int DIM>
class CPUHashTable {
  public:
	/*
	 * 查找keys在表中是否存在，若存在则返回对应的value
	 * @param n: keys的数量
	 * @param keys: 要查的keys
	 * @param values: 要返回的values
	 * @param exists: 返回keys对应位置的在表中是否存在
	 */
	unordered_map<K, int> MP[1024];
	V *T[2000007];
	int tot, cnt;
	void find(size_t n, const K *keys, ull *values, bool *exists) {
		for (int i = 0; i < n; ++i) {
			if (MP[keys[i] & 1023].count(keys[i])) {
				int id = MP[keys[i] & 1023][keys[i]];
				values[i] = (ull)T[id];
				exists[i] = 1;
			} else {
				exists[i] = 0;
			}
		}
	}

	/*
	 * 写入keys，values到表中。
	 * @param n: keys的数量
	 * @param keys: 要写的keys
	 * @param values: 要写的values
	 */
	void insert(size_t n, const K *keys, V *values) {
		for (int i = 0; i < n; ++i) {
			int id = 0;
			if (!MP[keys[i] & 1023].count(keys[i]))
				id = MP[keys[i] & 1023][keys[i]] = ++tot;
			else
				id = MP[keys[i] & 1023][keys[i]];
			T[id] = values + i * DIM;
		}
	}
};
