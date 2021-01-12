/*
 *  CBAuth_API.h
 *  CBAuth
 *
 *  Created on 9/11/10.
 *
 */
#ifndef CBAuth__API__HH__
#define CBAuth__API__HH__

/*
#define PLATFORM_CONTROL_BITS_SECURITY \
"{ \
{ 0x03, {0x761072E5, 0x6D8FD64A, 0x26CB15E4, 0x94EB47BD, 0x61C31629}}, \
{ 0x79, {0x7C95897B, 0x9B82B904, 0x373EB73E, 0xFD2619E1, 0x8E0E9BF5}}, \
{ 0x7A, {0x12EDDA46, 0xC8257D47, 0x0E1A2DEB, 0x0B0A08F7, 0x7410FDA7}}, \
{ 0x82, {0x150658D9, 0x2ABD5739, 0x81651C6A, 0x266215F6, 0x5873185E}}, \
{ 0x83, {0x8273F5C2, 0x679853B0, 0x3348A2A5, 0xF330173E, 0x48B8A6C9}}, \
{ 0x84, {0x269317AA, 0xA52022F4, 0x903CEDE1, 0xC466235C, 0x46175B89}}, \
{ 0x8A, {0x23C986A6, 0x6F29FB9D, 0xCC4F8B54, 0xA26BEC78, 0xAEE5D2ED}}, \
{ 0x9B, {0x45BCDDC6, 0x9BDE5680, 0x9E360903, 0xC5C37AC5, 0x763F70F2}}, \
{ 0x9C, {0x50029B86, 0xED5265F0, 0xC7C764B8, 0x88F066FF, 0xF8A863D1}}, \
{ 0x9D, {0xE5862CAD, 0xD7006612, 0x681B0000, 0x6605FF54, 0x8C700272}}, \
{ 0xBD, {0xE3A01F62, 0xEEE8EEEC, 0x52BAAF8F, 0x1C2B69CE, 0x8D9DE862}}, \
{ 0xBE, {0x59E2EE2F, 0x479CF9E0, 0x31518014, 0x7DB23FE8, 0xB78CD56C}}, \
}"*/

#define KeySize 20

#ifdef WIN32
	#define EXPORT __declspec(dllexport)
#else
	#ifndef EXPORT
		#define EXPORT __attribute__((visibility("default")))
	#endif
#endif     //WIN32

#ifdef __OBJC__

	#import <Foundation/Foundation.h>
	EXPORT  unsigned char * CreateSHA1(unsigned char  *aucKey, unsigned char  *aucNounce);
	EXPORT	unsigned char * CreateSHA1File(const char *acpFileName);
	EXPORT	void FreeSHA1Buffer(unsigned char * aucPtr);
	EXPORT  const char * cbauthVersion(void);
	EXPORT	bool ControlBitsToCheck(int *ipControlBitsArray,size_t *sLength, char ** acpControlBitNames );
	EXPORT	bool ControlBitsToClearOnPass(int *ipControlBitsArray,size_t *sLength );
	EXPORT	bool ControlBitsToClearOnFail(int *ipControlBitsArray,size_t *sLength );
	EXPORT	bool StationSetControlBit();
	EXPORT  int  StationFailCountAllowed( void );

	/*new apis for the ccc-eee codes*/		
	
	EXPORT  const char * cbSNGetVersion(void);

	EXPORT 	int GetCountCBsToCheckSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToCheckSN( const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength, char ** acpControlBitNames );

	EXPORT 	int GetCountCBsToClearOnPassSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToClearOnPassSN(const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength );

	EXPORT 	int GetCountCBsToClearOnFailSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToClearOnFailSN(const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength );

	EXPORT	int StationSetControlBitSN(const char * cpSerialNumber);
	EXPORT  int StationFailCountAllowedSN(const char * cpSerialNumber);

	EXPORT  const char * cbGetErrMsg(int errNum);



#else /* __OBJC__ */



#ifdef __cplusplus
	extern "C" {
#else
	#include<stdbool.h>
#endif
		
	/*
	creates a sha1 digest and returns it via allocating memory, after successfully calling it 
	call FreeSHA1Buffer to release the memory else we would have memory leak
	returns NULL if not successfull. aucKey and aucNounce are 20 bytes long, raw data. api also returns 
	20 bytes of raw data.
	*/
	EXPORT	unsigned char * CreateSHA1(unsigned char *aucKey ,unsigned char * aucNounce);

	/*Creates and returns a 160 bit or 20 byte Sha1 digest of a file, given the filename with path
	developer has call FreeSHA1Buffer api to release the memory */
	EXPORT	unsigned char * CreateSHA1File(const char *acpFileName);

	
	/*Call this api to release memory after calling CreateSHA1 api	*/
	EXPORT	void FreeSHA1Buffer(unsigned char * aucPtr);
		
	/* returns version string */
	EXPORT const char * cbauthVersion(void);
		
		
	/*
	 Extract the info from gh_station_info.json file and passed back through int ** and array length
	 validate the length of the array and extract values from ipControlBitsArray. 
	 Do not forget the free the memory after using the int and char arrayy.
	*/
	EXPORT	bool ControlBitsToCheck(int *ipControlBitsArray,size_t *sLength, char ** acpControlBitNames );
	EXPORT	bool ControlBitsToClearOnPass(int *ipControlBitsArray,size_t *sLength );
	EXPORT	bool ControlBitsToClearOnFail(int *ipControlBitsArray,size_t *sLength );
	EXPORT	bool StationSetControlBit();
	EXPORT  int  StationFailCountAllowed( void );
		
/*new apis for the ccc-eee codes*/		
	
	
	EXPORT  const char * cbSNGetVersion(void);
	
	EXPORT 	int GetCountCBsToCheckSN(const char * cpSerialNumber);	
	EXPORT	int ControlBitsToCheckSN( const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength, char ** acpControlBitNames );

	EXPORT 	int GetCountCBsToClearOnPassSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToClearOnPassSN(const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength );
	
	EXPORT 	int GetCountCBsToClearOnFailSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToClearOnFailSN(const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength );

	EXPORT	int StationSetControlBitSN(const char * cpSerialNumber);
	EXPORT  int StationFailCountAllowedSN(const char * cpSerialNumber);

	EXPORT  const char * cbGetErrMsg(int errNum);


		

#ifdef __cplusplus
	}
#endif


#endif /* __OBJ__ */
#endif /* CBAuth__API__HH__ */

