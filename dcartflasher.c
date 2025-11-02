/*--------------------------------------------------------------------*/
/* DCartFlasher                                                       */
/* by GienekP                                                         */
/* (c) 2023                                                           */
/*--------------------------------------------------------------------*/
#include <stdio.h>
/*--------------------------------------------------------------------*/
#include "dcartflasher.h"
#include "block.h"
#include "last.h"
/*--------------------------------------------------------------------*/
typedef unsigned char U8;
/*--------------------------------------------------------------------*/
U8 cardata[512*1024+16];
/*--------------------------------------------------------------------*/
char ach(char c)
{
	char r=0;
	if ((c>32) && (c<96)) {r=c+32;};
	if ((c>='a') && (c<='z')) {r=c;};
	return r;
}
/*--------------------------------------------------------------------*/
void save(const char *filename, U8 *data, unsigned int size)
{
	unsigned int i,j;
	FILE *pf;
	pf=fopen(filename,"wb");
	if (pf)
	{
		printf("Prepare DCart flasher.\n");
		fwrite(dcartflasher_xex,sizeof(U8),sizeof(dcartflasher_xex),pf);
		printf("Save Menu\n");
		for (j=0; j<64; j++)
		{
			unsigned int noempty=0;
			block_xex[7]=j;
			for (i=0; i<8192; i++)
			{
				U8 d=data[8192*j+i];
				block_xex[24+i]=d;
				if (d!=0xff) {noempty=1;};
			};
			if (noempty)
			{
				fwrite(&block_xex[2],sizeof(U8),sizeof(block_xex)-2,pf);
				printf("Save bank:$%02X Sum=$%02X XOR=$%02X\n",j,dcartflasher_xex[6+j],dcartflasher_xex[6+64+j]);
			}
			else
			{
				printf("Avoid bank %02X\n",j);
			};
		};
		fwrite(&last_xex[2],sizeof(U8),sizeof(last_xex)-2,pf);
		fclose(pf);
		printf("Save XEX \"%s\".\n",filename);
	};	
}
/*--------------------------------------------------------------------*/
void clear(U8 *data, unsigned int size)
{
	unsigned int i;
	for (i=0; i<size; i++) {data[i]=0xFF;};
}
/*--------------------------------------------------------------------*/
void calcsums(U8 *data, const char *title)
{
	unsigned int j,i;
	for (j=0; j<64; j++)
	{
		U8 sum=0,xor=0;
		for (i=0; i<8192; i++)
		{
			U8 b=data[8192*j+i];
			sum+=b;
			xor^=b;
		};
		dcartflasher_xex[6+j]=sum;
		dcartflasher_xex[6+64+j]=xor;
	};
	printf("Calc checksums.\n");
	for (i=0; i<32; i++)
	{
		U8 c=title[i];
		if (c) {dcartflasher_xex[6+128+i]=ach(c);} else {i=32;};
	};
	printf("Add title \"%s\".\n",title);
}
/*--------------------------------------------------------------------*/
unsigned int toInt(const U8 *str)
{
	unsigned int i,ret=0;
	for (i=0; i<4; i++)
	{
		ret<<=8;
		ret|=(unsigned int)(str[i]);
	};
	return ret;
}
/*--------------------------------------------------------------------*/
unsigned int car(U8 *data, unsigned int size)
{
	unsigned int ret=size;
	if (toInt(&data[0])==0x43415254)
	{
		unsigned int i,sum=0,rs=toInt(&data[8]);
		for (i=16; i<size; i++) {sum+=data[i];};
		if (sum==rs)
		{
			for (i=0; i<(size-16); i++) {data[i]=data[i+16];};
			for (i=(size-16); i<size; i++) {data[i]=0xFF;};
			ret-=16;
			printf("Detect CAR header, convert to bin.\n");
		};
	};
	return ret;
}
/*--------------------------------------------------------------------*/
unsigned int load(const char *filename, U8 *data, unsigned int size)
{
	unsigned int ret=0;
	FILE *pf;
	pf=fopen(filename,"rb");
	if (pf)
	{
		ret=fread(data,sizeof(U8),size,pf);
		fclose(pf);
		printf("Load \"%s\" size %i bytes.\n",filename,ret);
	};
	return ret;
}
/*--------------------------------------------------------------------*/
void flashBuilder(const char *title, const char *filein, const char *fileout)
{
	const unsigned int maxsize=sizeof(cardata);
	unsigned int size;
	clear(cardata,maxsize);
	size=load(filein,cardata,sizeof(cardata));
	if (size>0)
	{
		size=car(cardata,size);
		calcsums(cardata,title);
		save(fileout,cardata,2*1024*1024);
	}
	else
	{
		printf("Can't convert \"%s\"\n",filein);
	};
}
/*--------------------------------------------------------------------*/
int main( int argc, char* argv[] )
{		
	printf("DCart Flasher - ver: %s\n",__DATE__);
	switch (argc)
	{
		case 2:
		{
			flashBuilder(argv[1],argv[1],"FLASHER.XEX");

		} break;
		case 3:
		{
			flashBuilder(argv[1],argv[1],argv[2]);

		} break;
		case 4:
		{
			flashBuilder(argv[1],argv[2],argv[3]);

		} break;
		default:
		{
			printf("(c) GienekP\n");
			printf("use:\ndcartflasher title file.bincar flasher.xex\n");
			printf("dcartflasher file.bincar flasher.xex\n");
			printf("dcartflasher file.bincar\n");
		} break;
	};
	return 0;
}
/*--------------------------------------------------------------------*/
