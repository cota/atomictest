/*
 * License: CC0 (Public domain) - see LICENSE file for details
 */
#include <sys/time.h>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

typedef struct {
	int counter;
} atomic_t;

static inline void atomic_inc(atomic_t *a)
{
	__sync_fetch_and_add(&a->counter, 1);
}

#ifdef __sparc__
static inline unsigned long cmpxchg_u32(volatile int *m, int old, int new)
{
	__asm__ __volatile__("cas [%2], %3, %0"
			     : "=&r" (new)
			     : "" (new), "r" (m), "r" (old)
			     : "memory");
	return new;
}

static inline unsigned long atomic_cmpxchg(atomic_t *a, int old, int new)
{
	return cmpxchg_u32(&atomic->counter, old, new);
}
#else
static inline unsigned long atomic_cmpxchg(atomic_t *a, int old, int new)
{
	return __sync_val_compare_and_swap(&a->counter, old, new);
}
#endif

static unsigned long ops = 1 << 19;
static unsigned long n_threads;
static atomic_t val;

static void *thread(void *args)
{
	unsigned long i;

	for (i = 0; i < ops; i++)
		atomic_cmpxchg(&val, 0, 0);

	return NULL;
}

static unsigned long tv_to_ul(struct timeval *tv)
{
	unsigned long ret = tv->tv_sec;

	ret *= 1000000;
	ret += tv->tv_usec;
	return ret;
}

int main(int argc, char *argv[])
{
	pthread_t *threads;
	struct timeval tv_start, tv_end;
	unsigned long start, end;
	unsigned long ns;
	int rc;
	int i;

	argc--;
	if (argc == 0)
		n_threads = 1;
	else
		n_threads = strtoul(argv[argc], NULL, 0);
	printf("%lu n_threads\n", n_threads);

	threads = calloc(n_threads, sizeof(pthread_t));
	if (threads == NULL) {
		perror("threads");
		exit(1);
	}

	rc = gettimeofday(&tv_start, NULL);
	if (rc) {
		perror("gettimeofday");
		exit(1);
	}

	for (i = 0; i < n_threads; i++) {
		rc = pthread_create(&threads[i], NULL, thread, NULL);
		if (rc) {
			perror("thread_create");
			exit(1);
		}
	}

	for (i = 0; i < n_threads; i++)
		pthread_join(threads[i], NULL);

	rc = gettimeofday(&tv_end, NULL);
	if (rc)
		perror("gettimeofday");

	start = tv_to_ul(&tv_start);
	end = tv_to_ul(&tv_end);
	ns = (end - start) * 1000;
	printf("%lu ns\n%lu ops\n%lu ns/access\n", ns, ops, ns / ops);

	return 0;
}
