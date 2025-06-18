#include ".obnc/artSocket.h"
#include <obnc/OBNC.h>

#define OBERON_SOURCE_FILENAME "artSocket.obn"

const int artSocket__SocketDesc_id;
const int *const artSocket__SocketDesc_ids[1] = {&artSocket__SocketDesc_id};
const OBNC_Td artSocket__SocketDesc_td = {artSocket__SocketDesc_ids, 1};

const int artSocket__AddrInfoDesc_id;
const int *const artSocket__AddrInfoDesc_ids[1] = {&artSocket__AddrInfoDesc_id};
const OBNC_Td artSocket__AddrInfoDesc_td = {artSocket__AddrInfoDesc_ids, 1};

artSocket__Socket_ artSocket__NewSocket_(void)
{
	return 0;
}


OBNC_INTEGER artSocket__Bind_(artSocket__Socket_ s_, const char address_[], OBNC_INTEGER address_len, OBNC_INTEGER port_)
{
	return 99;
}


OBNC_INTEGER artSocket__Listen_(artSocket__Socket_ s_, OBNC_INTEGER backlog_)
{
	return 99;
}


artSocket__Socket_ artSocket__Accept_(artSocket__Socket_ s_, OBNC_INTEGER *err_)
{

	(*err_) = 99;
	return 0;
}


OBNC_INTEGER artSocket__Connect_(artSocket__Socket_ s_, const char address_[], OBNC_INTEGER address_len, OBNC_INTEGER port_)
{
	return 99;
}


OBNC_INTEGER artSocket__Send_(artSocket__Socket_ s_, const char data_[], OBNC_INTEGER data_len, OBNC_INTEGER len_, OBNC_INTEGER *sent_)
{

	(*sent_) = 0;
	return 99;
}


OBNC_INTEGER artSocket__Receive_(artSocket__Socket_ s_, char data_[], OBNC_INTEGER data_len, OBNC_INTEGER maxLen_, OBNC_INTEGER *received_)
{

	(*received_) = 0;
	return 99;
}


void artSocket__Close_(artSocket__Socket_ s_)
{
}


artSocket__AddrInfo_ artSocket__GetAddrInfo_(const char host_[], OBNC_INTEGER host_len, OBNC_INTEGER port_)
{
	return 0;
}


void artSocket__FreeAddrInfo_(artSocket__AddrInfo_ ai_)
{
}


OBNC_INTEGER artSocket__LastError_(artSocket__Socket_ s_)
{
	return 99;
}


void artSocket__Init(void)
{
}
