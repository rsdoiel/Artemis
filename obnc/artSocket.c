#include ".obnc/artSocket.h"
#include <obnc/OBNC.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <stdint.h>
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
    struct artSocket__SocketDesc_ *desc = OBNC_Allocate(sizeof(struct artSocket__SocketDesc_), OBNC_REGULAR_ALLOC);
    if (!desc) {
        close(fd);
        return 0;
    }
    desc->handle_ = fd;
    desc->lastError_ = 0;
    return (artSocket__Socket_)desc;
}


OBNC_INTEGER artSocket__Bind_(artSocket__Socket_ s_, const char address_[], OBNC_INTEGER address_len, OBNC_INTEGER port_)
{
    struct artSocket__SocketDesc_ *desc = (struct artSocket__SocketDesc_*)s_;
    if (!desc || desc->handle_ < 0) return ART_CLOSED;
    char portstr[16];
    snprintf(portstr, sizeof(portstr), "%d", (int)port_);
    struct addrinfo hints, *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE;
    int ret = getaddrinfo(address_, portstr, &hints, &res);
    if (ret != 0) {
        desc->lastError_ = ART_UNKNOWNERROR;
        return ART_UNKNOWNERROR;
    }
    int opt = 1;
    setsockopt(desc->handle_, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    int err = 0;
    if (bind(desc->handle_, res->ai_addr, res->ai_addrlen) < 0) {
        err = errno;
        desc->lastError_ = map_errno(err);
        freeaddrinfo(res);
        return desc->lastError_;
    }
    freeaddrinfo(res);
    desc->lastError_ = ART_OK;
    return ART_OK;
}


OBNC_INTEGER artSocket__Listen_(artSocket__Socket_ s_, OBNC_INTEGER backlog_)
{
    struct artSocket__SocketDesc_ *desc = (struct artSocket__SocketDesc_*)s_;
    if (!desc || desc->handle_ < 0) return ART_CLOSED;
    if (listen(desc->handle_, (int)backlog_) < 0) {
        int err = errno;
        desc->lastError_ = map_errno(err);
        return desc->lastError_;
    }
    desc->lastError_ = ART_OK;
    return ART_OK;
}


artSocket__Socket_ artSocket__Accept_(artSocket__Socket_ s_, OBNC_INTEGER *err_)
{
    struct artSocket__SocketDesc_ *desc = (struct artSocket__SocketDesc_*)s_;
    if (!desc || desc->handle_ < 0) {
        if (err_) *err_ = ART_CLOSED;
        return 0;
    }
    int client_fd = accept(desc->handle_, NULL, NULL);
    if (client_fd < 0) {
        int err = errno;
        if (err_) *err_ = map_errno(err);
        return 0;
    }
    // Set non-blocking
    int flags = fcntl(client_fd, F_GETFL, 0);
    if (flags >= 0) fcntl(client_fd, F_SETFL, flags | O_NONBLOCK);
    struct artSocket__SocketDesc_ *client_desc = OBNC_Allocate(sizeof(struct artSocket__SocketDesc_), OBNC_REGULAR_ALLOC);
    if (!client_desc) {
        close(client_fd);
        if (err_) *err_ = ART_UNKNOWNERROR;
        return 0;
    }
    client_desc->handle_ = client_fd;
    client_desc->lastError_ = ART_OK;
    if (err_) *err_ = ART_OK;
    return (artSocket__Socket_)client_desc;
}


OBNC_INTEGER artSocket__Connect_(artSocket__Socket_ s_, const char address_[], OBNC_INTEGER address_len, OBNC_INTEGER port_)
{
    struct artSocket__SocketDesc_ *desc = (struct artSocket__SocketDesc_*)s_;
    if (!desc || desc->handle_ < 0) return ART_CLOSED;
    char portstr[16];
    snprintf(portstr, sizeof(portstr), "%d", (int)port_);
    struct addrinfo hints, *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    int ret = getaddrinfo(address_, portstr, &hints, &res);
    if (ret != 0) {
        desc->lastError_ = ART_UNKNOWNERROR;
        return ART_UNKNOWNERROR;
    }
    int err = 0;
    if (connect(desc->handle_, res->ai_addr, res->ai_addrlen) < 0) {
        err = errno;
        desc->lastError_ = map_errno(err);
        freeaddrinfo(res);
        return desc->lastError_;
    }
    freeaddrinfo(res);
    desc->lastError_ = ART_OK;
    return ART_OK;
}


OBNC_INTEGER artSocket__Send_(artSocket__Socket_ s_, const char data_[], OBNC_INTEGER data_len, OBNC_INTEGER len_, OBNC_INTEGER *sent_)
{
    struct artSocket__SocketDesc_ *desc = (struct artSocket__SocketDesc_*)s_;
    if (!desc || desc->handle_ < 0) {
        if (sent_) *sent_ = 0;
        return ART_CLOSED;
    }
    int n = send(desc->handle_, data_, (size_t)len_, 0);
    if (n < 0) {
        int err = errno;
        if (sent_) *sent_ = 0;
        desc->lastError_ = map_errno(err);
        return desc->lastError_;
    }
    if (sent_) *sent_ = n;
    desc->lastError_ = ART_OK;
    return ART_OK;
}


OBNC_INTEGER artSocket__Receive_(artSocket__Socket_ s_, char data_[], OBNC_INTEGER data_len, OBNC_INTEGER maxLen_, OBNC_INTEGER *received_)
{
    struct artSocket__SocketDesc_ *desc = (struct artSocket__SocketDesc_*)s_;
    if (!desc || desc->handle_ < 0) {
        if (received_) *received_ = 0;
        return ART_CLOSED;
    }
    int n = recv(desc->handle_, data_, (size_t)maxLen_, 0);
    if (n < 0) {
        int err = errno;
        if (received_) *received_ = 0;
        desc->lastError_ = map_errno(err);
        return desc->lastError_;
    }
    if (received_) *received_ = n;
    desc->lastError_ = ART_OK;
    return ART_OK;
}


void artSocket__Close_(artSocket__Socket_ s_)
{
    struct artSocket__SocketDesc_ *desc = (struct artSocket__SocketDesc_*)s_;
    if (desc) {
        if (desc->handle_ >= 0) close(desc->handle_);
        desc->handle_ = -1;
        // GC will reclaim desc
    }
}


artSocket__AddrInfo_ artSocket__GetAddrInfo_(const char host_[], OBNC_INTEGER host_len, OBNC_INTEGER port_)
{
    char portstr[16];
    snprintf(portstr, sizeof(portstr), "%d", (int)port_);
    struct addrinfo hints, *res = NULL;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    int ret = getaddrinfo(host_, portstr, &hints, &res);
    if (ret != 0 || res == NULL) return 0;
    struct artSocket__AddrInfoDesc_ *ai = OBNC_Allocate(sizeof(struct artSocket__AddrInfoDesc_), OBNC_REGULAR_ALLOC);
    if (!ai) {
        freeaddrinfo(res);
        return 0;
    }
    ai->addrPtr_ = (OBNC_INTEGER)(uintptr_t)res;
    return (artSocket__AddrInfo_)ai;
}


void artSocket__FreeAddrInfo_(artSocket__AddrInfo_ ai_)
{
    struct artSocket__AddrInfoDesc_ *ai = (struct artSocket__AddrInfoDesc_*)ai_;
    if (ai && ai->addrPtr_ != 0) {
        struct addrinfo *res = (struct addrinfo *)(uintptr_t)ai->addrPtr_;
        freeaddrinfo(res);
        ai->addrPtr_ = 0;
    }
}


OBNC_INTEGER artSocket__LastError_(artSocket__Socket_ s_)
{
    struct artSocket__SocketDesc_ *desc = (struct artSocket__SocketDesc_*)s_;
    if (!desc) return ART_UNKNOWNERROR;
    return desc->lastError_;
}


void artSocket__Init(void)
{
}
