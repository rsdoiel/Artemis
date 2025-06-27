#include "artDirent.h"
#include <obnc/OBNC.h>
#include <sys/types.h>
#include <dirent.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>

#define OBERON_SOURCE_FILENAME "artDirent.obn"

const int artDirent__DirScannerDesc_id;
const int *const artDirent__DirScannerDesc_ids[1] = {&artDirent__DirScannerDesc_id};
const OBNC_Td artDirent__DirScannerDesc_td = {artDirent__DirScannerDesc_ids, 1};

artDirent__DirScanner_ artDirent__OpenScanner_(const char path_[], OBNC_INTEGER path_len)
{
	artDirent__DirScanner_ scanner_ = 0;
	DIR* dir;

	OBNC_NEW(scanner_, &artDirent__DirScannerDesc_td, struct artDirent__DirScannerDesc_Heap, OBNC_ATOMIC_NOINIT_ALLOC);
	
	/* Try to open the directory */
	dir = opendir(path_);
	if (dir != NULL) {
		/* Store DIR* as integer handle (cast pointer to uintptr_t to integer) */
		(*OBNC_PT(scanner_, __LINE__)).handle_ = dir;
		(*OBNC_PT(scanner_, __LINE__)).isOpen_ = 1;
		(*OBNC_PT(scanner_, __LINE__)).hasError_ = 0;
	} else {
		/* Failed to open directory */
		(*OBNC_PT(scanner_, __LINE__)).handle_ = 0;
		(*OBNC_PT(scanner_, __LINE__)).isOpen_ = 0;
		(*OBNC_PT(scanner_, __LINE__)).hasError_ = 1;
	}
	
	return scanner_;
}


int artDirent__NextEntry_(artDirent__DirScanner_ scanner_, char name_[], OBNC_INTEGER name_len, int *isDirectory_)
{
	int result_;
	DIR* dir;
	struct dirent* entry;
	size_t nameLength;

	result_ = 0;
	name_[OBNC_IT(0, name_len, __LINE__)] = '\x00';
	(*isDirectory_) = 0;
	
	if (scanner_ != 0 && (*OBNC_PT(scanner_, __LINE__)).isOpen_ && !(*OBNC_PT(scanner_, __LINE__)).hasError_) {
		/* Convert handle back to DIR* */
		dir = (DIR*)(uintptr_t)(*OBNC_PT(scanner_, __LINE__)).handle_;
		
		/* Clear errno to distinguish between error and end-of-directory */
		errno = 0;
		entry = readdir(dir);
		
		if (entry != NULL) {
			/* Successfully read an entry */
			nameLength = strlen(entry->d_name);
			
			/* Copy filename, ensuring we don't overflow the buffer */
			if (nameLength < (size_t)(name_len - 1)) {
				strcpy(name_, entry->d_name);
			} else {
				/* Truncate if name is too long */
				strncpy(name_, entry->d_name, name_len - 1);
				name_[name_len - 1] = '\x00';
			}
			
			/* Determine if this is a directory */
			/* Use d_type if available, otherwise assume it's not a directory */
			#ifdef DT_DIR
			if (entry->d_type == DT_DIR) {
				(*isDirectory_) = 1;
			} else {
				(*isDirectory_) = 0;
			}
			#else
			/* d_type not available - assume not directory */
			(*isDirectory_) = 0;
			#endif
			
			result_ = 1;  /* Successfully read entry */
		} else {
			/* readdir returned NULL - check if error or end of directory */
			if (errno != 0) {
				/* An error occurred */
				(*OBNC_PT(scanner_, __LINE__)).hasError_ = 1;
			}
			/* If errno is 0, we've reached end of directory (normal) */
			result_ = 0;
		}
	}
	
	return result_;
}


void artDirent__CloseScanner_(artDirent__DirScanner_ *scanner_)
{
	DIR* dir;

	if ((*scanner_) != 0) {
		if ((*OBNC_PT((*scanner_), __LINE__)).isOpen_) {
			/* Convert handle back to DIR* and close it */
			dir = (DIR*)(uintptr_t)(*OBNC_PT((*scanner_), __LINE__)).handle_;
			if (dir != NULL) {
				closedir(dir);
			}
			(*OBNC_PT((*scanner_), __LINE__)).isOpen_ = 0;
		}
		(*scanner_) = 0;
	}
}


int artDirent__IsValid_(artDirent__DirScanner_ scanner_)
{
	int result_;

	result_ = 0;
	if (scanner_ != 0) {
		result_ = (*OBNC_PT(scanner_, __LINE__)).isOpen_ && (! (*OBNC_PT(scanner_, __LINE__)).hasError_);
	}
	return result_;
}


void artDirent__Init(void)
{
}
