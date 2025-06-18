#include ".obnc/artSocket.h"
#include <obnc/OBNC.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#define OBERON_SOURCE_FILENAME "artSocket.obn"

// C struct for Oberon SocketDesc
typedef struct {
    int fd;
    int lastError;
} artSocket_SocketDesc;

// C struct for Oberon AddrInfoDesc
typedef struct {
    struct addrinfo *ai;
} artSocket_AddrInfoDesc;

// Oberon error codes
enum {
    ART_OK = 0,
    ART_WOULDBLOCK = 1,
    ART_INPROGRESS = 2,
    ART_INTERRUPTED = 3,
    ART_NOTCONNECTED = 4,
    ART_ALREADYCONNECTED = 5,
    ART_CONNECTIONREFUSED = 6,
    ART_TIMEDOUT = 7,
    ART_HOSTUNREACHABLE = 8,
    ART_NETWORKUNREACHABLE = 9,
    ART_ADDRINUSE = 10,
    ART_ADDRNOTAVAILABLE = 11,
    ART_CLOSED = 12,
    ART_UNKNOWNERROR = 99
};

static int map_errno(int err) {
    switch (err) {
        case 0: return ART_OK;
        case EAGAIN: return ART_WOULDBLOCK;
        case EINPROGRESS: return ART_INPROGRESS;
        case EINTR: return ART_INTERRUPTED;
        case ENOTCONN: return ART_NOTCONNECTED;
        case EISCONN: return ART_ALREADYCONNECTED;
        case ECONNREFUSED: return ART_CONNECTIONREFUSED;
        case ETIMEDOUT: return ART_TIMEDOUT;
        case EHOSTUNREACH: return ART_HOSTUNREACHABLE;
        case ENETUNREACH: return ART_NETWORKUNREACHABLE;
        case EADDRINUSE: return ART_ADDRINUSE;
        case EADDRNOTAVAIL: return ART_ADDRNOTAVAILABLE;
        case EBADF: return ART_CLOSED;
        default: return ART_UNKNOWNERROR;
    }
}

const int artSocket__SocketDesc_id;
const int *const artSocket__SocketDesc_ids[1] = {&artSocket__SocketDesc_id};
const OBNC_Td artSocket__SocketDesc_td = {artSocket__SocketDesc_ids, 1};

const int artSocket__AddrInfoDesc_id;
const int *const artSocket__AddrInfoDesc_ids[1] = {&artSocket__AddrInfoDesc_id};
const OBNC_Td artSocket__AddrInfoDesc_td = {artSocket__AddrInfoDesc_ids, 1};

artSocket__Socket_ artSocket__NewSocket_(void)
{
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) return 0;
    // Set non-blocking
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0 || fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0) {
        close(fd);
        return 0;
    }
    artSocket_SocketDesc *desc = malloc(sizeof(artSocket_SocketDesc));
    if (!desc) {
        close(fd);
        return 0;
    }
    desc->fd = fd;
    desc->lastError = 0;
    return (artSocket__Socket_)desc;
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
    artSocket_SocketDesc *desc = (artSocket_SocketDesc*)s_;
    if (!desc || desc->fd < 0) return ART_CLOSED;
    char portstr[16];
    snprintf(portstr, sizeof(portstr), "%d", (int)port_);
    struct addrinfo hints, *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    int ret = getaddrinfo(address_, portstr, &hints, &res);
    if (ret != 0) {
        desc->lastError = ART_UNKNOWNERROR;
        return ART_UNKNOWNERROR;
    }
    int err = 0;
    if (connect(desc->fd, res->ai_addr, res->ai_addrlen) < 0) {
        err = errno;
        desc->lastError = map_errno(err);
        freeaddrinfo(res);
        return desc->lastError;
    }
    freeaddrinfo(res);
    desc->lastError = ART_OK;
    return ART_OK;
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
    artSocket_SocketDesc *desc = (artSocket_SocketDesc*)s_;
    if (desc) {
        if (desc->fd >= 0) close(desc->fd);
        desc->fd = -1;
        free(desc);
    }
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
