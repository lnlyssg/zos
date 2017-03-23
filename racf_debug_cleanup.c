/**
 * Original author unknown
 * Enhancements made by Dhiru Kholia <dhiru.kholia at gmail.com>
 *
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <ctype.h>

enum field_class {
	CLASS_GROUP = 1,
	CLASS_CHAR = 2,
	CLASS_INT = 4,
	CLASS_DATE = 32,
	CLASS_TIME = 64,
	CLASS_HASH = 128
};

struct profile {
	int id;
	char *desc;
	enum field_class class;
};

/**
 * http://publib.boulder.ibm.com/infocenter/zos/v1r13/topic/com.ibm.zos.r13.icha300/rtegt.htm#rtegt
 */
struct profile profile_group[] = {
	{.id = 2, "ENTYPE", CLASS_INT},
	{.id = 3, "VERSION", CLASS_INT},
	{.id = 4, "SUPGROUP", CLASS_CHAR},
	{.id = 5, "AUTHDATE", CLASS_DATE},
	{.id = 6, "AUTHOR", CLASS_CHAR},
	{.id = 7, "INITCNT", CLASS_INT},
	{.id = 8, "UACC", CLASS_INT},
	{.id = 9, "NOTRMUAC", CLASS_INT},
	{.id = 10, "INSTDATA", CLASS_CHAR},
	{.id = 11, "MODELNAM", CLASS_CHAR},
	{.id = 12, "FLDCNT", CLASS_GROUP},
	{.id = 13, "FLDNAME", CLASS_CHAR},
	{.id = 14, "FLDVALUE", CLASS_INT},
	{.id = 15, "FLDFLAG", CLASS_INT},
	{.id = 16, "SUBGRPCT", CLASS_GROUP},
	{.id = 17, "SUBGRPNM", CLASS_CHAR},
	{.id = 18, "ACLCNT", CLASS_GROUP},
	{.id = 19, "USERID", CLASS_CHAR},
	{.id = 20, "USERACS", CLASS_INT},
	{.id = 21, "ACSCNT", CLASS_INT},
	{.id = 22, "USRCNT", CLASS_GROUP},
	{.id = 23, "USRNM", CLASS_CHAR},
	{.id = 24, "USRDATA", CLASS_INT},
	{.id = 25, "USRFLG", CLASS_INT},
	{.id = 26, "UNVFLG", CLASS_INT},
};

/**
 * http://publib.boulder.ibm.com/infocenter/zos/v1r13/topic/com.ibm.zos.r13.icha300/rteut.htm#rteut
 */
struct profile profile_user[] = {
	{.id = 2, "ENTYPE", CLASS_INT},
	{.id = 3, "VERSION", CLASS_INT},
	{.id = 4, "AUTHDATE", CLASS_DATE},
	{.id = 5, "AUTHOR", CLASS_CHAR},
	{.id = 6, "FLAG1", CLASS_INT},
	{.id = 7, "FLAG2", CLASS_INT},
	{.id = 8, "FLAG3", CLASS_INT},
	{.id = 9, "FLAG4", CLASS_INT},
	{.id = 10, "FLAG5", CLASS_INT},
	{.id = 11, "PASSINT", CLASS_INT},
	{.id = 12, "PASSWORD", CLASS_HASH},
	{.id = 13, "PASSDATE", CLASS_DATE},
	{.id = 14, "PGMRNAME", CLASS_CHAR},
	{.id = 15, "DFLTGRP", CLASS_CHAR},
	{.id = 16, "LJTIME", CLASS_TIME},
	{.id = 17, "LJDATE", CLASS_DATE},
	{.id = 18, "INSTDATA", CLASS_CHAR},
	{.id = 19, "UAUDIT", CLASS_INT},
	{.id = 20, "FLAG6", CLASS_INT},
	{.id = 21, "FLAG7", CLASS_INT},
	{.id = 22, "FLAG8", CLASS_INT},
	{.id = 23, "MAGSTRIP", CLASS_INT},
	{.id = 24, "PWDGEN", CLASS_INT},
	{.id = 25, "PWDCNT", CLASS_GROUP},
	{.id = 26, "OLDPWDNM", CLASS_INT},
	{.id = 27, "OLDPWD", CLASS_CHAR},
	{.id = 28, "REVOKECT", CLASS_INT},
	{.id = 29, "MODELNAM", CLASS_CHAR},
	{.id = 30, "SECLEVEL", CLASS_INT},
	{.id = 31, "NUMCTGY", CLASS_GROUP},
	{.id = 32, "CATEGORY", CLASS_INT},
	{.id = 33, "REVOKEDT", CLASS_DATE},
	{.id = 34, "RESUMEDT", CLASS_DATE},
	{.id = 35, "LOGDAYS", CLASS_INT},
	{.id = 36, "LOGTIME", CLASS_TIME},
	{.id = 37, "FLDCNT", CLASS_INT},
	{.id = 38, "FLDNAME", CLASS_INT},
	{.id = 39, "FLDVALUE", CLASS_INT},
	{.id = 40, "FLDFLAG", CLASS_INT},
	{.id = 41, "CLCNT", CLASS_GROUP},
	{.id = 42, "CLNAME", CLASS_CHAR},
	{.id = 43, "CONGRPCT", CLASS_GROUP},
	{.id = 44, "CONGRPNM", CLASS_CHAR},
	{.id = 45, "USRCNT", CLASS_GROUP},
	{.id = 46, "USRNM", CLASS_CHAR},
	{.id = 47, "USRDATA", CLASS_INT},
	{.id = 48, "USRFLG", CLASS_INT},
	{.id = 49, "SECLABEL", CLASS_CHAR},
	{.id = 50, "CGGRPCT", CLASS_GROUP},
	{.id = 51, "CGGRPNM", CLASS_CHAR},
	{.id = 52, "CGAUTHDA", CLASS_DATE},
	{.id = 53, "CGAUTHOR", CLASS_CHAR},
	{.id = 54, "CGLJTIME", CLASS_TIME},
	{.id = 55, "CGLJDATE", CLASS_DATE},
	/* not complete */
	{.id = 67, "TUCNT", CLASS_INT},
	{.id = 68, "TUKEY", CLASS_CHAR},
	{.id = 70, "CERTCT", CLASS_GROUP},
	{.id = 71, "CERTNAME", CLASS_GROUP},
	/* not complete */
	{.id = 88, "PHRDATE", CLASS_DATE},
	{.id = 89, "PHRGEN", CLASS_INT},
	{.id = 90, "PHRCNT", CLASS_GROUP},
	{.id = 92, "OLDPHR", CLASS_CHAR},
	{.id = 93, "CERTSEQN", CLASS_INT},
};

/**
 * http://publib.boulder.ibm.com/infocenter/zos/v1r13/topic/com.ibm.zos.r13.icha300/rtect.htm#rtect
 */
struct profile profile_connect[] = {
	{.id = 2, "ENTYPE", CLASS_INT},
	{.id = 3, "VERSION", CLASS_INT},
	{.id = 4, "AUTHDATE", CLASS_DATE},
	{.id = 5, "AUTHOR", CLASS_CHAR},
	{.id = 6, "LJTIME", CLASS_TIME},
	{.id = 7, "LJDATE", CLASS_DATE},
	{.id = 8, "UACC", CLASS_INT},
	{.id = 9, "INITCNT", CLASS_INT},
	{.id = 10, "FLAG1", CLASS_INT},
	{.id = 11, "FLAG2", CLASS_INT},
	{.id = 12, "FLAG3", CLASS_INT},
	{.id = 13, "FLAG4", CLASS_INT},
	{.id = 14, "FLAG5", CLASS_INT},
	{.id = 15, "NOTRMUAC", CLASS_INT},
	{.id = 16, "GRPAUDIT", CLASS_INT},
	{.id = 17, "REVOKEDT", CLASS_DATE},
	{.id = 18, "RESUMEDT", CLASS_DATE},
};

/**
 * http://publib.boulder.ibm.com/infocenter/zos/v1r13/topic/com.ibm.zos.r13.icha300/rtedst.htm#rtedst
 */
struct profile profile_dataset[] = {
	{.id = 2, "ENTYPE", CLASS_INT},
	{.id = 3, "VERSION", CLASS_INT},
	{.id = 4, "CREADATE", CLASS_DATE},
	{.id = 5, "AUTHOR", CLASS_CHAR},
	{.id = 6, "LREFDAT", CLASS_DATE},
	{.id = 7, "LCHGDAT", CLASS_DATE},
	{.id = 8, "ACSALTR", CLASS_INT},
	{.id = 9, "ACSCNTL", CLASS_INT},
	{.id = 10, "ACSUPDT", CLASS_INT},
	{.id = 11, "ACSREAD", CLASS_INT},
	{.id = 12, "UNIVACS", CLASS_INT},
	{.id = 13, "FLAG1", CLASS_INT},
	{.id = 14, "AUDIT", CLASS_INT},
	{.id = 15, "GROUPNM", CLASS_CHAR},
	{.id = 16, "DSTYPE", CLASS_INT},
	{.id = 17, "LEVEL", CLASS_INT},
	{.id = 18, "DEVTYP", CLASS_INT},
	{.id = 19, "DEVTYPX", CLASS_CHAR},
	{.id = 20, "GAUDIT", CLASS_INT},
	{.id = 21, "INSTDATA", CLASS_CHAR},
	{.id = 22, "AUDITQS", CLASS_INT},
	{.id = 23, "AUDITQF", CLASS_INT},
	{.id = 24, "GAUDITQS", CLASS_INT},
	{.id = 25, "GAUDITQF", CLASS_INT},
	{.id = 26, "WARNING", CLASS_INT},
	{.id = 27, "SECLEVEL", CLASS_INT},
	{.id = 28, "NUMCTGY", CLASS_GROUP},
	{.id = 29, "CATEGORY", CLASS_INT},
	{.id = 30, "NOTIFY", CLASS_CHAR},
	{.id = 31, "RETPD", CLASS_INT},
	{.id = 32, "ACL2CNT", CLASS_GROUP},
	{.id = 33, "PROGRAM", CLASS_CHAR},
	{.id = 34, "USER2ACS", CLASS_CHAR},
	{.id = 35, "PROGACS", CLASS_INT},
	{.id = 36, "PACSCNT", CLASS_INT},
	{.id = 37, "ACL2VAR", CLASS_CHAR},
	{.id = 38, "FLDCNT", CLASS_GROUP},
	{.id = 39, "FLDNAME", CLASS_CHAR},
	{.id = 40, "FLDVALUE", CLASS_INT},
	{.id = 41, "FLDFLAG", CLASS_INT},
	{.id = 42, "VOLCNT", CLASS_GROUP},
	{.id = 43, "VOLSER", CLASS_CHAR},
	{.id = 44, "ACLCNT", CLASS_GROUP},
	{.id = 45, "USERID", CLASS_CHAR},
	{.id = 46, "USERACS", CLASS_INT},
	{.id = 47, "ACSCNT", CLASS_INT},
	{.id = 48, "USRCNT", CLASS_INT},
	{.id = 49, "USRNM", CLASS_CHAR},
	{.id = 50, "USRDATA", CLASS_INT},
	{.id = 51, "USRFLG", CLASS_INT},
	{.id = 52, "SECLABEL", CLASS_CHAR},
};

/**
 * http://publib.boulder.ibm.com/infocenter/zos/v1r13/topic/com.ibm.zos.r13.icha300/rtegrt.htm#rtegrt
 */
struct profile profile_general[] = {
	{.id = 2, "ENTYPE", CLASS_INT},
	{.id = 3, "VERSION", CLASS_INT},
	{.id = 4, "CLASTYPE", CLASS_INT},
	{.id = 5, "DEFDATE", CLASS_DATE},
	{.id = 6, "OWNER", CLASS_CHAR},
	{.id = 7, "LREFDAT", CLASS_DATE},
	{.id = 8, "LCHGDAT", CLASS_DATE},
	{.id = 9, "ACSALTR", CLASS_INT},
	{.id = 10, "ACSCNTL", CLASS_INT},
	{.id = 11, "ACSUPDT", CLASS_INT},
	{.id = 12, "ACSREAD", CLASS_INT},
	{.id = 13, "UACC", CLASS_INT},
	{.id = 14, "AUDIT", CLASS_INT},
	{.id = 15, "LEVEL", CLASS_INT},
	{.id = 16, "GAUDIT", CLASS_INT},
	{.id = 17, "INSTDATA", CLASS_CHAR},
	{.id = 18, "AUDITQS", CLASS_INT},
	{.id = 19, "AUDITQF", CLASS_INT},
	{.id = 20, "GAUDITQS", CLASS_INT},
	{.id = 21, "GAUDITQF", CLASS_INT},
	{.id = 22, "WARNING", CLASS_INT},
	{.id = 23, "RESFLG", CLASS_INT},
	{.id = 24, "TVTOCCNT", CLASS_GROUP},
	{.id = 25, "TVTOCSEQ", CLASS_INT},
	{.id = 26, "TVTOCCRD", CLASS_DATE},
	{.id = 27, "TVTOCIND", CLASS_INT},
	{.id = 28, "TVTOCDSN", CLASS_CHAR},
	{.id = 29, "TVTOCVOL", CLASS_CHAR},
	{.id = 30, "TVTOCRDS", CLASS_CHAR},
	{.id = 31, "NOTIFY", CLASS_CHAR},
	{.id = 32, "LOGDAYS", CLASS_INT},
	{.id = 33, "LOGTIME", CLASS_TIME},
	{.id = 34, "LOGZONE", CLASS_INT},
	{.id = 35, "NUMCTGY", CLASS_GROUP},
	{.id = 36, "CATEGORY", CLASS_INT},
	/* not complete */
	{.id = 42, "APPLDATA", CLASS_CHAR},
	{.id = 43, "MEMCNT", CLASS_GROUP},
	{.id = 44, "MEMLST", CLASS_INT},
	{.id = 45, "VOLCNT", CLASS_GROUP},
	{.id = 46, "VOLSER", CLASS_CHAR},
	{.id = 47, "ACLCNT", CLASS_GROUP},
	{.id = 48, "USERID", CLASS_CHAR},
	{.id = 49, "USERACS", CLASS_INT},
	{.id = 50, "ACSCNT", CLASS_INT},
	{.id = 51, "USRCNT", CLASS_GROUP},
	{.id = 52, "USRNM", CLASS_CHAR},
	{.id = 53, "USRDATA", CLASS_INT},
	{.id = 54, "USRFLG", CLASS_INT},
	{.id = 55, "SECLABEL", CLASS_CHAR},
	{.id = 56, "ACL2CNT", CLASS_GROUP},
	{.id = 57, "ACL2NAME", CLASS_CHAR},
	{.id = 58, "ACL2UID", CLASS_CHAR},
	/* not complete */
};

static char BASE[8] = { 0xC2, 0xC1, 0xE2, 0xC5, 0x40, 0x40, 0x40, 0x40 };

static unsigned char e2a[256] = {
	0, 1, 2, 3, 156, 9, 134, 127, 151, 141, 142, 11, 12, 13, 14, 15,
	16, 17, 18, 19, 157, 133, 8, 135, 24, 25, 146, 143, 28, 29, 30, 31,
	128, 129, 130, 131, 132, 10, 23, 27, 136, 137, 138, 139, 140, 5, 6, 7,
	144, 145, 22, 147, 148, 149, 150, 4, 152, 153, 154, 155, 20, 21, 158,
	    26,
	32, 160, 161, 162, 163, 164, 165, 166, 167, 168, 91, 46, 60, 40, 43, 33,
	38, 169, 170, 171, 172, 173, 174, 175, 176, 177, 93, 36, 42, 41, 59, 94,
	45, 47, 178, 179, 180, 181, 182, 183, 184, 185, 124, 44, 37, 95, 62, 63,
	186, 187, 188, 189, 190, 191, 192, 193, 194, 96, 58, 35, 64, 39, 61, 34,
	195, 97, 98, 99, 100, 101, 102, 103, 104, 105, 196, 197, 198, 199, 200,
	    201,
	202, 106, 107, 108, 109, 110, 111, 112, 113, 114, 203, 204, 205, 206,
	    207, 208,
	209, 126, 115, 116, 117, 118, 119, 120, 121, 122, 210, 211, 212, 213,
	    214, 215,
	216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229,
	    230, 231,
	123, 65, 66, 67, 68, 69, 70, 71, 72, 73, 232, 233, 234, 235, 236, 237,
	125, 74, 75, 76, 77, 78, 79, 80, 81, 82, 238, 239, 240, 241, 242, 243,
	92, 159, 83, 84, 85, 86, 87, 88, 89, 90, 244, 245, 246, 247, 248, 249,
	48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 250, 251, 252, 253, 254, 255
};

int racf_date_to_bcd(int packed)
{
	int days = 0, year = 0;
	packed >>= 4;		// assume sign can be safely ignored

	/* Return Jan 1, 1970 for NULL dates */
	if (packed < 16 || packed == 0xffffff)
		return 1970 << 12 | 1;

	/* days */
	days += packed & 0xf;
	packed >>= 4;
	days += 10 * (packed & 0xf);
	packed >>= 4;
	days += 100 * (packed & 0xf);
	packed >>= 4;

	year = packed & 0xf;
	packed >>= 4;
	year += 10 * (packed & 0xf);
	packed >>= 4;
	if (year >= 71)
		year += 1900;
	else
		year += 2000;

	return (days | year << 12);
}

void dump_hex(char *prefix, void *data, int len)
{
	unsigned char *ptr = (unsigned char *)data;
	int i, j;

	printf("%s:%s", prefix,
	       len >= 16 ? "\n" : strlen(prefix) >= 8 ? "\t" : "\t\t");
	for (i = 0; i < len; i++) {
		if (i % 32 == 0)
			printf("\t");
		printf("%02x", ptr[i]);
		if (i % 32 == 31) {
			printf(" [");
			for (j = i - 31; j <= i; j++)
				printf("%c%s",
				       isprint(e2a[ptr[j]]) ? e2a[ptr[j]] : '?',
				       j % 32 == 31 ? "]\n" : j % 8 ==
				       7 ? "] [" : "");
		} else if (i % 8 == 7)
			printf(" ");
	}
	if (i % 32) {
		for (j = i; j % 32; j++)
			printf("  %s", j % 8 == 7 ? " " : "");
		printf("%s[", j % 8 == 7 ? " " : "");
		for (j = i - i % 32; j < i; j++)
			printf("%c%s", isprint(e2a[ptr[j]]) ? e2a[ptr[j]] : '?',
			       j % 32 == 31 ? "]" "\n" : j % 8 ==
			       7 ? "] [" : "");
	}

	if (!len)
		printf("<zero length input>\n");
}

/**
 * Extract Type, Length, Value
 */
int extract_tlv(unsigned char *src, int *type, int *length, unsigned char *dst)
{
	int i;

	*type = *src++;
	i = *length = *src++;
	for (i = 0; i < *length; i++)
		*dst++ = *src++;

	return 2 + i;
}

/**
 * Parse RACF profile fields
 */
int parse_profile_chunk(unsigned char *origin, int nlen, struct profile *profile_entries,
		 int nprofile)
{
	unsigned char *ptr = origin;
	int field_id, prev_field_id, field_length;
	int occurences, j, field_count, k, datalen;
	int tlvs, i;
	unsigned int value;
	unsigned char buf[0x10000];
	unsigned char username[256];
	struct profile *profile;
	int consumed;

	for (i = 0; i < nlen; i++)
		username[i] = e2a[origin[i - nlen]];
	username[nlen] = 0;

	prev_field_id = 0;
	consumed = 0;
	for (tlvs = 0; tlvs < nprofile; tlvs++) {
		field_id = *ptr++;
		if ((field_length = *ptr++) & 0x80) {
			field_length &= ~0x80;
			field_length <<= 24;
			field_length += *ptr++ << 16;
			field_length += *ptr++ << 8;
			field_length += *ptr++ << 0;
			consumed += 4;
		} else
			consumed++;

		if (field_id == 0 && field_length == 0)
			return 0;
		else if (field_id < prev_field_id) {
			printf
			    ("  PARSE ERROR: Field ID %d with length %d is less than previous field ID %d, consumed 0x%04x bytes"
			     "\n", field_id, field_length, prev_field_id,
			     consumed);
			return -1;
		} else
			prev_field_id = field_id;

		if (field_length == 0) {
			printf("  PARSE ERROR: Field ID %d has zero length"
			       "\n", field_id);
			return -1;
		} else if (field_length >= 0x10000) {
			printf
			    ("  PARSE ERROR: Field ID %d has absurd length 0x%08x"
			     "\n", field_id, field_length);
			return -1;
		}

		profile = NULL;
		for (i = 0; i < nprofile; i++) {
			if (profile_entries[i].id != field_id)
				continue;

			profile = profile_entries + i;
			break;
		}

		if (!profile) {
			printf
			    ("  field ID=0x%02x, length=0x%02x at offset 0x%02x"
			     "\n", field_id, field_length,
			     (int)(ptr - 2 - origin + 8 + 3 + nlen));
			printf("  TODO: Unhandled field, skipping %d bytes"
			       "\n", field_length);
			while (field_length--) {
				ptr++;
				consumed++;
			}
			continue;
		}

		switch (profile->class) {
		case CLASS_INT:
			if (field_length == 1) {
				value = *ptr++;
			} else if (field_length == 2) {
				value = *ptr++ << 8;
				value += *ptr++;
			} else if (field_length == 4) {
				value = *ptr++ << 24;
				value += *ptr++ << 16;
				value += *ptr++ << 8;
				value += *ptr++;
			}

			printf("  [0x%02x] %s: 0x%02x\n", field_id, profile->desc,
			       value);

			consumed += field_length;
			break;

		case CLASS_CHAR:
			for (i = 0; i < field_length; i++)
				buf[i] = e2a[*ptr++];
			buf[i] = 0;
			printf("  [0x%02x] %s: '%s'\n", field_id, profile->desc,
			       buf);
			consumed += field_length;
			break;

		case CLASS_TIME:
			value = *ptr++ << 24;
			value += *ptr++ << 16;
			value += *ptr++ << 8;
			value += *ptr++;
			printf
			    ("  [0x%02x] %s: Time as packed decimal: 0x%08x\n",
			     field_id, profile->desc, value);
			consumed += field_length;
			break;

		case CLASS_DATE:
			value = *ptr++ << 16;
			value += *ptr++ << 8;
			value += *ptr++;
			printf
			    ("  [0x%02x] %s: year %d, day %d (packed decimal: 0x%08x)\n",
			     field_id, profile->desc, racf_date_to_bcd(value) >> 12,
			     racf_date_to_bcd(value) & 0xfff, value);
			consumed += field_length;
			break;

		case CLASS_HASH:
			/* printf("  [0x%02x] %s: DES hash '$racf$*%s*", field_id,
			       profile->desc, username);
			for (i = 0; i < field_length; i++)
				printf("%02X", *ptr++);
			printf("'\n"); */
			printf("$racf$*%s*", username);
			for (i = 0; i < field_length; i++)
				printf("%02X", *ptr++);
			printf("\n");
			consumed += field_length;
			break;

		case CLASS_GROUP:
			{
				int lc = 0;

				occurences = *ptr++ << 24;
				occurences += *ptr++ << 16;
				occurences += *ptr++ << 8;
				occurences += *ptr++;
				consumed += 4;
				lc += 4;
				printf
				    ("  [0x%02x] %s: Repeat group with %d occurences, total length %d, consumed before start 0x%04x\n",
				     field_id, profile->desc, occurences,
				     field_length, lc);
				if (occurences > 64) {
					printf
					    ("  PARSE ERROR: Repeat group has absurd number of occurences, consumed 0x%04x bytes so far (locally 0x%04x, %d)"
					     "\n", consumed, lc, lc);
					return -1;
				}
				/*
				   else if(occurences == 0)
				   occurences = 1;
				 */

				for (i = 0; i < occurences; i++) {
					field_count = *ptr++;
					consumed++;
					lc++;
					for (j = 0; j < field_count; j++) {
						datalen = *ptr++;
						consumed++;
						lc++;
						printf
						    ("      Entry %d, field %d of %d, datalen %d, data: ",
						     i + 1, j + 1, field_count,
						     datalen);

						/* XXX - Kludge to print old DES hashes */
						if (field_id == 0x19
						    && field_count == 2
						    && j == 1)
							printf("\n$racf$*%s*",
							       username);

						value = datalen;	/* isprintable */
						for (k = 0; k < datalen;
						     k++, consumed++, lc++) {
							buf[k] = *ptr++;
							printf("%02X", buf[k]);
							buf[k] = e2a[buf[k]];
							if (!isprint(buf[k]))
								value = 0;
						}

						buf[k] = 0;

						if (field_id == 0x19
						    && field_count == 2
						    && j == 1)
							printf("");
						else if (value)
							printf(" '%s'", buf);

						printf("\n");
					}
				}

				printf
				    ("      END of repeat group, consumed %d of %d bytes, 0x%04x total"
				     "\n", lc, field_length, consumed);
			}
			break;
		}
	}

	return consumed;
}

int main(int argc, char **argv)
{
	int i, j, fd, len, ret;
	struct stat st;
	unsigned char *data, *ptr;
	unsigned char buf[1024];

	if ((fd = open(argv[1], O_RDONLY)) < 0) {
		perror("open()");
		exit(1);
	}

	stat(argv[1], &st);
	if ((data =
	     mmap(NULL, st.st_size, PROT_READ, MAP_SHARED, fd,
		  0)) == MAP_FAILED) {
		perror("mmap()");
		exit(1);
	}

	close(fd);

	ptr = data;
	for (i = 0; i < st.st_size; i++) {
		int type, length, physlen, loglen;
		unsigned char entype[1];

		if (data[i] != 0x83 || memcmp(data + i + 9, BASE, sizeof(BASE)))
			continue;

		if (0 && ptr != data + i)
			fprintf(stdout,
				"MISS: i=0x%08x, data=0x%04x, ptr=0x%04x, diff=0x%04x\n",
				i, i, ptr - data, data + i - ptr);

		/* Record header */
		ptr = &data[i + 1];
		/* Physical record length */
		physlen = *ptr++ << 24;
		physlen += *ptr++ << 16;
		physlen += *ptr++ << 8;
		physlen += *ptr++ << 0;
		/* Logical record length, actual data */
		loglen = *ptr++ << 24;
		loglen += *ptr++ << 16;
		loglen += *ptr++ << 8;
		loglen += *ptr++ << 0;
		/* Segment name */
		ptr += sizeof(BASE);
		/* Profile name length */
		len = *ptr++ << 8;
		len += *ptr++;
		/* Reserved */
		ptr++;
		/* Profile name */
		for (j = 0; j < len; j++) {
			buf[j] = e2a[*ptr++];
		}
		buf[len] = 0;

		printf
		    ("Found profile at 0x%08x, physical length 0x%04x, logical length 0x%04x, profile length %d, profile name '%s'"
		     "\n", i, physlen, loglen, len, buf);

		/* Get ENTYPE */
		extract_tlv(ptr, &type, &length, entype);
		switch (entype[0]) {
		case 0x01:	/* GROUP */
			printf("  GROUP profile: '%s'\n", buf);
			ret =
			    parse_profile_chunk(ptr, len, profile_group,
					 sizeof(profile_group) /
					 sizeof(profile_group[0]));
			break;
		case 0x02:	/* USER */
			printf("  USER profile: '%s'\n", buf);
			ret =
			    parse_profile_chunk(ptr, len, profile_user,
					 sizeof(profile_user) /
					 sizeof(profile_user[0]));
			break;
		case 0x03:	/* CONNECT */
			printf("  CONNECT profile: '%s'\n", buf);
			ret =
			    parse_profile_chunk(ptr, len, profile_connect,
					 sizeof(profile_connect) /
					 sizeof(profile_connect[0]));
			break;
		case 0x04:	/* DATA SET */
			printf("  DATA SET profile: '%s'\n", buf);
			ret =
			    parse_profile_chunk(ptr, len, profile_dataset,
					 sizeof(profile_dataset) /
					 sizeof(profile_dataset[0]));
			break;
		case 0x05:	/* GENERAL */
			printf("  GENERAL profile: '%s'\n", buf);
			ret =
			    parse_profile_chunk(ptr, len, profile_general,
					 sizeof(profile_general) /
					 sizeof(profile_general[0]));
			break;
		default:
			printf("  UNKNOWN profile %d: '%s'\n", entype[0], buf);
			ret = -1;
			break;
		}

		if (ret < 0)
			dump_hex("DEBUG: Profile record", data + i,
				    loglen + 32 - loglen % 32);
		else
			printf
			    ("DONE, consumed 0x%04x (%d) bytes of 0x%04x (%d)\n",
			     ret, ret, loglen, loglen);
		ptr = &data[i + physlen];
		i += physlen - 1;
	}

	return 0;
}