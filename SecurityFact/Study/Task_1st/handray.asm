
./handray/handray/handray:     file format elf64-x86-64


Disassembly of section .init:

0000000000401000 <_init>:
  401000:	f3 0f 1e fa          	endbr64
  401004:	48 83 ec 08          	sub    rsp,0x8
  401008:	48 8b 05 e9 2f 00 00 	mov    rax,QWORD PTR [rip+0x2fe9]        # 403ff8 <__gmon_start__@Base>
  40100f:	48 85 c0             	test   rax,rax
  401012:	74 02                	je     401016 <_init+0x16>
  401014:	ff d0                	call   rax
  401016:	48 83 c4 08          	add    rsp,0x8
  40101a:	c3                   	ret

Disassembly of section .plt:

0000000000401020 <.plt>:
  401020:	ff 35 e2 2f 00 00    	push   QWORD PTR [rip+0x2fe2]        # 404008 <_GLOBAL_OFFSET_TABLE_+0x8>
  401026:	f2 ff 25 e3 2f 00 00 	bnd jmp QWORD PTR [rip+0x2fe3]        # 404010 <_GLOBAL_OFFSET_TABLE_+0x10>
  40102d:	0f 1f 00             	nop    DWORD PTR [rax]
  401030:	f3 0f 1e fa          	endbr64
  401034:	68 00 00 00 00       	push   0x0
  401039:	f2 e9 e1 ff ff ff    	bnd jmp 401020 <_init+0x20>
  40103f:	90                   	nop
  401040:	f3 0f 1e fa          	endbr64
  401044:	68 01 00 00 00       	push   0x1
  401049:	f2 e9 d1 ff ff ff    	bnd jmp 401020 <_init+0x20>
  40104f:	90                   	nop
  401050:	f3 0f 1e fa          	endbr64
  401054:	68 02 00 00 00       	push   0x2
  401059:	f2 e9 c1 ff ff ff    	bnd jmp 401020 <_init+0x20>
  40105f:	90                   	nop
  401060:	f3 0f 1e fa          	endbr64
  401064:	68 03 00 00 00       	push   0x3
  401069:	f2 e9 b1 ff ff ff    	bnd jmp 401020 <_init+0x20>
  40106f:	90                   	nop
  401070:	f3 0f 1e fa          	endbr64
  401074:	68 04 00 00 00       	push   0x4
  401079:	f2 e9 a1 ff ff ff    	bnd jmp 401020 <_init+0x20>
  40107f:	90                   	nop

Disassembly of section .plt.sec:

0000000000401080 <puts@plt>:
  401080:	f3 0f 1e fa          	endbr64
  401084:	f2 ff 25 8d 2f 00 00 	bnd jmp QWORD PTR [rip+0x2f8d]        # 404018 <puts@GLIBC_2.2.5>
  40108b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000401090 <write@plt>:
  401090:	f3 0f 1e fa          	endbr64
  401094:	f2 ff 25 85 2f 00 00 	bnd jmp QWORD PTR [rip+0x2f85]        # 404020 <write@GLIBC_2.2.5>
  40109b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

00000000004010a0 <printf@plt>:
  4010a0:	f3 0f 1e fa          	endbr64
  4010a4:	f2 ff 25 7d 2f 00 00 	bnd jmp QWORD PTR [rip+0x2f7d]        # 404028 <printf@GLIBC_2.2.5>
  4010ab:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

00000000004010b0 <read@plt>:
  4010b0:	f3 0f 1e fa          	endbr64
  4010b4:	f2 ff 25 75 2f 00 00 	bnd jmp QWORD PTR [rip+0x2f75]        # 404030 <read@GLIBC_2.2.5>
  4010bb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

00000000004010c0 <exit@plt>:
  4010c0:	f3 0f 1e fa          	endbr64
  4010c4:	f2 ff 25 6d 2f 00 00 	bnd jmp QWORD PTR [rip+0x2f6d]        # 404038 <exit@GLIBC_2.2.5>
  4010cb:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

Disassembly of section .text:

00000000004010d0 <_start>:
  4010d0:	f3 0f 1e fa          	endbr64
  4010d4:	31 ed                	xor    ebp,ebp
  4010d6:	49 89 d1             	mov    r9,rdx
  4010d9:	5e                   	pop    rsi
  4010da:	48 89 e2             	mov    rdx,rsp
  4010dd:	48 83 e4 f0          	and    rsp,0xfffffffffffffff0
  4010e1:	50                   	push   rax
  4010e2:	54                   	push   rsp
  4010e3:	45 31 c0             	xor    r8d,r8d
  4010e6:	31 c9                	xor    ecx,ecx
  4010e8:	48 c7 c7 6c 12 40 00 	mov    rdi,0x40126c
  4010ef:	ff 15 fb 2e 00 00    	call   QWORD PTR [rip+0x2efb]        # 403ff0 <__libc_start_main@GLIBC_2.34>
  4010f5:	f4                   	hlt
  4010f6:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
  4010fd:	00 00 00 

0000000000401100 <_dl_relocate_static_pie>:
  401100:	f3 0f 1e fa          	endbr64
  401104:	c3                   	ret
  401105:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
  40110c:	00 00 00 
  40110f:	90                   	nop

0000000000401110 <deregister_tm_clones>:
  401110:	b8 50 40 40 00       	mov    eax,0x404050
  401115:	48 3d 50 40 40 00    	cmp    rax,0x404050
  40111b:	74 13                	je     401130 <deregister_tm_clones+0x20>
  40111d:	b8 00 00 00 00       	mov    eax,0x0
  401122:	48 85 c0             	test   rax,rax
  401125:	74 09                	je     401130 <deregister_tm_clones+0x20>
  401127:	bf 50 40 40 00       	mov    edi,0x404050
  40112c:	ff e0                	jmp    rax
  40112e:	66 90                	xchg   ax,ax
  401130:	c3                   	ret
  401131:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
  401138:	00 00 00 00 
  40113c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401140 <register_tm_clones>:
  401140:	be 50 40 40 00       	mov    esi,0x404050
  401145:	48 81 ee 50 40 40 00 	sub    rsi,0x404050
  40114c:	48 89 f0             	mov    rax,rsi
  40114f:	48 c1 ee 3f          	shr    rsi,0x3f
  401153:	48 c1 f8 03          	sar    rax,0x3
  401157:	48 01 c6             	add    rsi,rax
  40115a:	48 d1 fe             	sar    rsi,1
  40115d:	74 11                	je     401170 <register_tm_clones+0x30>
  40115f:	b8 00 00 00 00       	mov    eax,0x0
  401164:	48 85 c0             	test   rax,rax
  401167:	74 07                	je     401170 <register_tm_clones+0x30>
  401169:	bf 50 40 40 00       	mov    edi,0x404050
  40116e:	ff e0                	jmp    rax
  401170:	c3                   	ret
  401171:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
  401178:	00 00 00 00 
  40117c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

0000000000401180 <__do_global_dtors_aux>:
  401180:	f3 0f 1e fa          	endbr64
  401184:	80 3d c5 2e 00 00 00 	cmp    BYTE PTR [rip+0x2ec5],0x0        # 404050 <__TMC_END__>
  40118b:	75 13                	jne    4011a0 <__do_global_dtors_aux+0x20>
  40118d:	55                   	push   rbp
  40118e:	48 89 e5             	mov    rbp,rsp
  401191:	e8 7a ff ff ff       	call   401110 <deregister_tm_clones>
  401196:	c6 05 b3 2e 00 00 01 	mov    BYTE PTR [rip+0x2eb3],0x1        # 404050 <__TMC_END__>
  40119d:	5d                   	pop    rbp
  40119e:	c3                   	ret
  40119f:	90                   	nop
  4011a0:	c3                   	ret
  4011a1:	66 66 2e 0f 1f 84 00 	data16 cs nop WORD PTR [rax+rax*1+0x0]
  4011a8:	00 00 00 00 
  4011ac:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]

00000000004011b0 <frame_dummy>:
  4011b0:	f3 0f 1e fa          	endbr64
  4011b4:	eb 8a                	jmp    401140 <register_tm_clones>

00000000004011b6 <check>:
  4011b6:	f3 0f 1e fa          	endbr64
  4011ba:	55                   	push   rbp
  4011bb:	48 89 e5             	mov    rbp,rsp
  4011be:	48 83 ec 20          	sub    rsp,0x20
  4011c2:	48 8b 45 e0          	mov    rax,QWORD PTR [rbp-0x20]
  4011c6:	ba ef be ad de       	mov    edx,0xdeadbeef
  4011cb:	48 39 d0             	cmp    rax,rdx
  4011ce:	75 19                	jne    4011e9 <check+0x33>
  4011d0:	48 8d 05 2d 0e 00 00 	lea    rax,[rip+0xe2d]        # 402004 <_IO_stdin_used+0x4>
  4011d7:	48 89 c7             	mov    rdi,rax
  4011da:	e8 a1 fe ff ff       	call   401080 <puts@plt>
  4011df:	bf 01 00 00 00       	mov    edi,0x1
  4011e4:	e8 d7 fe ff ff       	call   4010c0 <exit@plt>
  4011e9:	48 8d 05 22 0e 00 00 	lea    rax,[rip+0xe22]        # 402012 <_IO_stdin_used+0x12>
  4011f0:	48 89 c7             	mov    rdi,rax
  4011f3:	e8 88 fe ff ff       	call   401080 <puts@plt>
  4011f8:	90                   	nop
  4011f9:	c9                   	leave
  4011fa:	c3                   	ret

00000000004011fb <print>:
  4011fb:	f3 0f 1e fa          	endbr64
  4011ff:	55                   	push   rbp
  401200:	48 89 e5             	mov    rbp,rsp
  401203:	48 83 ec 20          	sub    rsp,0x20
  401207:	48 c7 45 e0 00 00 00 	mov    QWORD PTR [rbp-0x20],0x0
  40120e:	00 
  40120f:	48 c7 45 e8 00 00 00 	mov    QWORD PTR [rbp-0x18],0x0
  401216:	00 
  401217:	48 c7 45 f0 00 00 00 	mov    QWORD PTR [rbp-0x10],0x0
  40121e:	00 
  40121f:	48 8d 45 e0          	lea    rax,[rbp-0x20]
  401223:	ba 17 00 00 00       	mov    edx,0x17
  401228:	48 89 c6             	mov    rsi,rax
  40122b:	bf 00 00 00 00       	mov    edi,0x0
  401230:	e8 7b fe ff ff       	call   4010b0 <read@plt>
  401235:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax
  401238:	83 7d fc 00          	cmp    DWORD PTR [rbp-0x4],0x0
  40123c:	75 11                	jne    40124f <print+0x54>
  40123e:	48 8d 05 d2 0d 00 00 	lea    rax,[rip+0xdd2]        # 402017 <_IO_stdin_used+0x17>
  401245:	48 89 c7             	mov    rdi,rax
  401248:	e8 33 fe ff ff       	call   401080 <puts@plt>
  40124d:	eb 1b                	jmp    40126a <print+0x6f>
  40124f:	48 8d 45 e0          	lea    rax,[rbp-0x20]
  401253:	48 89 c6             	mov    rsi,rax
  401256:	48 8d 05 be 0d 00 00 	lea    rax,[rip+0xdbe]        # 40201b <_IO_stdin_used+0x1b>
  40125d:	48 89 c7             	mov    rdi,rax
  401260:	b8 00 00 00 00       	mov    eax,0x0
  401265:	e8 36 fe ff ff       	call   4010a0 <printf@plt>
  40126a:	c9                   	leave
  40126b:	c3                   	ret

000000000040126c <main>:
  40126c:	f3 0f 1e fa          	endbr64
  401270:	55                   	push   rbp
  401271:	48 89 e5             	mov    rbp,rsp
  401274:	48 83 ec 20          	sub    rsp,0x20
  401278:	89 7d ec             	mov    DWORD PTR [rbp-0x14],edi
  40127b:	48 89 75 e0          	mov    QWORD PTR [rbp-0x20],rsi
  40127f:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
  401286:	ba 02 00 00 00       	mov    edx,0x2
  40128b:	48 8d 05 90 0d 00 00 	lea    rax,[rip+0xd90]        # 402022 <_IO_stdin_used+0x22>
  401292:	48 89 c6             	mov    rsi,rax
  401295:	bf 01 00 00 00       	mov    edi,0x1
  40129a:	e8 f1 fd ff ff       	call   401090 <write@plt>
  40129f:	48 8d 45 fc          	lea    rax,[rbp-0x4]
  4012a3:	ba 02 00 00 00       	mov    edx,0x2
  4012a8:	48 89 c6             	mov    rsi,rax
  4012ab:	bf 00 00 00 00       	mov    edi,0x0
  4012b0:	e8 fb fd ff ff       	call   4010b0 <read@plt>
  4012b5:	48 8d 45 fc          	lea    rax,[rbp-0x4]
  4012b9:	0f b6 00             	movzx  eax,BYTE PTR [rax]
  4012bc:	0f b6 c0             	movzx  eax,al
  4012bf:	83 f8 33             	cmp    eax,0x33
  4012c2:	74 2e                	je     4012f2 <main+0x86>
  4012c4:	83 f8 33             	cmp    eax,0x33
  4012c7:	7f 35                	jg     4012fe <main+0x92>
  4012c9:	83 f8 31             	cmp    eax,0x31
  4012cc:	74 07                	je     4012d5 <main+0x69>
  4012ce:	83 f8 32             	cmp    eax,0x32
  4012d1:	74 0e                	je     4012e1 <main+0x75>
  4012d3:	eb 29                	jmp    4012fe <main+0x92>
  4012d5:	b8 00 00 00 00       	mov    eax,0x0
  4012da:	e8 1c ff ff ff       	call   4011fb <print>
  4012df:	eb 1e                	jmp    4012ff <main+0x93>
  4012e1:	48 8d 05 3d 0d 00 00 	lea    rax,[rip+0xd3d]        # 402025 <_IO_stdin_used+0x25>
  4012e8:	48 89 c7             	mov    rdi,rax
  4012eb:	e8 90 fd ff ff       	call   401080 <puts@plt>
  4012f0:	eb 0d                	jmp    4012ff <main+0x93>
  4012f2:	b8 00 00 00 00       	mov    eax,0x0
  4012f7:	e8 ba fe ff ff       	call   4011b6 <check>
  4012fc:	eb 01                	jmp    4012ff <main+0x93>
  4012fe:	90                   	nop
  4012ff:	eb 85                	jmp    401286 <main+0x1a>

Disassembly of section .fini:

0000000000401304 <_fini>:
  401304:	f3 0f 1e fa          	endbr64
  401308:	48 83 ec 08          	sub    rsp,0x8
  40130c:	48 83 c4 08          	add    rsp,0x8
  401310:	c3                   	ret
