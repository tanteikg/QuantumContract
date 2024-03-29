#ifndef GIFENC_H
#define GIFENC_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _blob
{
	unsigned char *Blob;
	int Blobptr;
} dummyblob;

typedef struct ge_GIF {
    uint16_t w, h;
    int depth;
    int bgindex;
    struct _blob * fd;
    int offset;
    int nframes;
    uint8_t *frame, *back;
    uint32_t partial;
    uint8_t buffer[0xFF];
} ge_GIF;

ge_GIF *ge_new_gif(
    unsigned char *blob, uint16_t width, uint16_t height,
    uint8_t *palette, int depth, int bgindex, int loop
);
void ge_add_frame(ge_GIF *gif, uint16_t delay);
int ge_close_gif(ge_GIF* gif);

#ifdef __cplusplus
}
#endif
#endif /* GIFENC_H */
