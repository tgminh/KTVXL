.model small 
.stack 100
.data
    note    DB 10,13, 'Chon bai (1-5): $' 
    note11  DB 10,13, 'Nhap chuoi: $'
    string  DB 50   ; chuoi dai max 50 ky tu
            DB ?    ; do dai thuc cua chuoi tai string+1
            DB 50 DUP('$')
    note12  DB 10,13, 'Chuoi da nhap: $'    
    note21  DB ' - pos $'
    brkl    DB 10,13, '$'
    
    note31  DB 10,13, 'Tan suat xuat hien: $'
    freqTable   DB 128 DUP(0)   ;max 127 ky tu
    dash    DB ' -- $'
    slash   DB '/$'
    comma   DB ',$'
    
    sortString1 DB 50 DUP('$')
    note41 DB 10,13, 'Chuoi da sap xep: $'
    
    note51 DB 10,13, 'Ky tu da sap xep va tan suat tuong ung: $'
.code
main proc
    ; load du lieu tu .data vao DS
    mov AX, @DATA
    mov DS, AX
    
    ;hien thi yeu cau chon bai so may
    mov AH, 9h
    lea DX, note
    int 21h
    
    ;ghi nhan bai nguoi dung chon
    mov AH, 01h
    int 21h
    sub AL, '0' ;chuyen ve interger 
    
    ;nhay toi bai da chon
    cmp AL, 1
    je task1
    cmp AL, 2
    je task2
    cmp AL, 3
    je task3
    cmp AL, 4
    je task4
    cmp AL,5
    je task5
    jmp exit

exit:    
    mov AH, 4Ch
    int 21h
    
task1: ;bai1: nhap chuoi tu ban phim
    call inputString
    call print
    jmp exit
    
task2: ;bai2: tim ky tu la so va hien thi vi tri tuong ung
    call numPos
    jmp exit    
 
task3: ;bai3: tan suat xuat hien kem vi tri ky tu
    call inputString
    call freqTrack
    jmp exit
task4:  ;bai4: sap xep chuoi va lap du so lan xuat hien cac ky tu
    call inputString
    call sort1
    jmp exit
task5:  ;bai5: sap xep chuoi va hien thi cung so lan xuat hien (tan suat)
    call inputString
    call sort2
    jmp exit

main endp

inputString proc ;bai1: ham lay chuoi nhap tu ban phim
    mov AH, 9h  ;hien thi yeu cau nhap chuoi
    lea DX, note11
    int 21h     ;interrupt tai day de hien thi note11
    ;co che tuong tu cho cac interrupt
    ;nhung chi tiet cac ham mov va load du lieu truoc do can duoc hieu dung
    
    mov AH, 0Ah
    lea DX, string
    int 21h
    
    xor BX, BX
    mov BL, string[1]   ;lay do dai chuoi vao BX 
    
    mov AH, 9h
    lea DX, brkl        ; xuong dong moi
    int 21h
    
    ret    
inputString endp

print proc ;ham hien thi chuoi
    mov AH, 9h      
    lea DX, note12
    int 21h         ;load va hien thi len man hinh note12
    
    mov AH, 9h
    lea DX, string+2    ;skip string va string+1 chua do dai max va do dai thuc te
    int 21h
    
    ret
print endp

numPos proc ;bai2: detect chu so va luu duoc vi tri cua no trong chuoi
    call inputString
    
    mov SI, 2   ;SI nhan gia tri 2 de dung phia sau, tro vào string+2
    xor BX, BX
    
    scan:
        mov AL, string[SI]  ;duyet tu string+2 ++ -> load gia tri vao AL de detect
        cmp AL, '0'         ;so sanh de chon gia tri la chu so: 0<=AL<=9
        jl notNum           ;AL<0 -> jump
        cmp AL, '9'
        jg notNum
        
        ;van la chu so thi chay tiep de hien thi gia tri
        mov DL, AL
        mov AH, 2h
        int 21h
        
        mov AH, 9h
        lea DX, note21
        int 21h             ;in ra khoang cach ' - pos'
        
        mov AX, SI          ;mov gia tri ve vi tri vao AX
        sub AX, 1           ;lay chuan
        call printPos       ;goi ham hien thi
        
        mov AH, 9h
        lea DX, brkl
        int 21h             ;xuong dong
        
    notNum: ;khong la chu so -> tang SI nhay toi ky tu tiep theo
        mov CL, string[1]
        mov CH, 0
        inc SI
        inc BX
        cmp BX, CX
        jne scan
    
    ret         
numPos endp

printPos proc   ;ham hien thi vi tri
    push AX     ;luu cac thanh ghi
    push DX
    push CX
    push DI
    
    mov DI, 10
    xor CX, CX  ;xoa
    split:      ;tach so bang cach chia 10 ra -> hang chuc va don vi rieng
        xor DX, DX
        div DI
        push DX ; luu du vao DX
        inc CX
        test AX, AX
        jnz split
        
    display:
        pop DX          ;doc tu stack
        add DL, '0'     ;chuyen so -> ascii
        mov AH, 2h
        int 21h
        
        loop display    ;lap den khi CX=0
    
    pop DI              ;lam sach thanh ghi
    pop CX
    pop DX
    pop AX
    
    ret 
printPos endp

freqTrack proc  ;bai3: ham tracking tan suat xuat hien cac ky tu    
    push AX            ;luu gia tri thanh ghi
    push BX
    push DX
    push CX
    push SI
    push DI
    
    xor SI, SI
    mov AH, 9h
    lea DX, note31
    int 21h     ;hien thi thong diep tuong ung
    
    mov AH, 9h
    lea DX, brkl        ; xuong dong moi
    int 21h
    
    lea DI, freqTable
    mov CX, 128
    xor AL, AL
    rep stosb
    
    lea SI, string+2    ;bat dau tro duyet tu dau chuoi 

count_loop:
    mov AL, [SI]        ;mov tung ky tu
    cmp AL, 0Dh
    je counted
    
    xor AH, AH      
    lea DI, freqTable   ;tro DH den bang
    add DI, AX          ;chi ra vi tri
    inc BYTE PTR[DI]    ;tang chi so tan suat
    inc SI              ;SI++ -> duyet ky tu tiep theo
    jmp count_loop

counted:
    mov CX, 0           ;CX thanh ascii

displayB3:
    lea DI, freqTable
    add DI, CX
    cmp BYTE PTR[DI], 0 ;tracking tan suat xuat hien
    je nextChar
    
    mov AH, 2h
    mov DL, CL          ;in ra ky tu dang kiem tra
    int 21h
    
    mov AH, 9h
    lea DX, dash         ;in ra concept de yeu cau '--'
    int 21h
    
    xor AH, AH           ;in ra chinh ky tu duyet duoc
    mov AL, [DI]
    call printPercent
    
    mov AH, 9h 
    lea DX, slash        ;in ra concept de yeu cau
    int 21h
    
    mov AX, BX           ;in ra tong so ky tu thuc chuoi
    call printPercent
    
    mov AH, 9h
    lea DX, dash         ;in ra concept de yeu cau
    int 21h
    
    push CX              ;lay CX
    lea SI, string+2     ;SI tro dau chuoi
    mov DI, 1            ;vi tri tu 1, ghi nhan boi DI 

findPos:
    mov AL, [SI]
    cmp AL, 0Dh          ;neu ket chuoi ->xuong dong va pop CX
    je  finPos
    
    cmp AL, CL
    jne nextPos           ;so sanh ky tu -> khac -> duyet tiep
    
    mov AX, DI            ;in ra vi tri neu giong
    call printPercent
    
    mov AH, 9h
    lea DX, comma         ;in ra concept de yeu cau
    int 21h
    
nextPos:
    inc SI              ;SI++ -> duyet tang
    inc DI
    jmp findPos
finPos:
    mov AH, 9h          ;xuong dong
    lea DX, brkl
    int 21h
    
    pop CX              ;pop lai CX
    
nextChar:
    inc CX
    cmp CX, 128         ;kiem tra gioi han
    jl displayB3
    
    pop DI               ;lam sach thanh ghi
    pop SI
    pop CX
    pop DX
    pop BX
    pop AX
    
    ret
freqTrack endp    
    
printPercent proc ;ham ho tro in ra cac gia tri ky tu duyet duoc theo yeu cau
    push AX             
    push BX
    push DX
    push CX             ;luu cac gia tri thanh ghi
    
    mov BX, 10          ;lay co so 10
    mov CX, 0           ;dem so chu so can in
    
splitPer:               ;neu can hien thi 2 chu so -> can tach
    mov DX, 0
    div BX              ;chia AX cho BX=10
    add DL, '0'         ;chuyen ket qua thanh ky tu 
    push DX             ;day vao stack
    inc CX              ;tang bien dem CX++
    test AX, AX         ;kiem tra CX=0
    jnz splitPer
    
printPer:
    pop DX              ;lay DX la ket qua vua day vao
    mov AH, 02h
    int 21h             ;in kq
    loop printPer       ;lap lai
    
    pop CX            ;lam sach thanh ghi
    pop DX
    pop BX
    pop AX
    
    ret      
printPercent endp          

sort1 proc ;bai 4: sap xep chuoi da nhap va hien thi lai voi du so lan xuat hien
    push AX            ;luu thanh ghi
    push BX
    push DX
    push CX
    push SI
    push DI
    
    lea DI, sortString1     ;tao chuoi de ghi ket qua
    mov CX, 50             
    mov AL, '$'
    rep stosb
    
    lea SI, string+2        ;si chi vao string+2
    lea DI, sortString1     ;di chi vao dau chuoi ket qua
    xor CX, CX
copy:                       ;copy va loc string vao sortString1
    mov al, [si]            ;kiem tra ket thuc chuoi
    cmp al, 0Dh
    je copy_fin
    
    cmp al, ' '             ;kiem tra va xoa dau cach
    je passChar
    mov [di], al            ;mov ky tu vao sortString 
    inc di                  ;tang di, cx 
    inc cx
passChar:
    inc si                  ;tang si de duyet tiep string
    jmp copy                ;quay lai copy den het string
copy_fin:
    cmp cx, 1               ;kiem tra do dai chuoi de nhan biet ket thuc
    jle sort_fin            ;dung va nhay den buoc sap xep
    dec cx                  ;--cx -> de sort
loop1:
    lea si, sortString1     ;bien dem cho loop2
    mov dx, cx
loop2:                      ;thuat toan sorting
    mov al, [si]            ;so sanh 2 ky tu ke nhau
    mov bl, [si+1]
    cmp al, bl
    
    jle const                ;khong doi cho
    mov [si], bl            ;doi cho neu can
    mov [si+1], al    
const:
    inc si                  ;si++ de duyet ky tu tiep theo
    dec dx
    jnz loop2
    loop loop1              ;duyet den khi thong het ->sorting
sort_fin:
    mov al, 9h              ;loat lenh giup hien thi; tuong tu cac phan tren
    lea dx, note41
    int 21h
    
    mov ah, 9h
    lea dx, sortString1
    int 21h
    
    mov ah, 9h
    lea dx, brkl
    int 21h
    
    pop DI            ;lam sach thanh ghi
    pop SI
    pop CX
    pop DX
    pop BX
    pop AX
    
    ret
sort1 endp

sort2 proc ;bai5: sap xep chuoi va hien thi kem so lan xuat hien
    push AX           ;luu gia tri than ghi
    push BX
    push DX
    push CX
    push SI
    push DI
    
    mov ah, 9h          ;hien thi thong diep
    lea dx, note51
    int 21h
    
    mov cx, 0           ;cx -> ascii
    xor bx, bx          ;xoa bx
    
    call subFreqTrackB5 ;loi dung hoat dong tuong tu bai 3 de tao bang kiem tra tan suat
loopFreq:
    lea di, freqTable
    add di, cx
    cmp BYTE PTR [di], 0;kiem tra xem co xuat hien ko 
    je nextCharB5       ; =0 -> bo qua
    
    cmp bx, 0
    je passDash
    
    mov ah, 9h
    lea dx, dash
    int 21h
    
passDash:
    inc BX               ; bx++ dem ky tu da in
    
    mov ah, 2h           ;in ky tu tuong ung
    mov dl, cl
    int 21h
    
    xor ah, ah           ; in tan suat
    mov al, [di]
    call printPercent
    
nextCharB5:
    inc CX               ; duyet ky tu tiep theo
    cmp CX, 128
    jl loopFreq
    
    mov ah, 9h
    lea dx, brkl
    int 21h
        
    pop DI                  ;lam sach thanh ghi
    pop SI
    pop CX
    pop DX
    pop BX
    pop AX
    
    ret
sort2 endp

subFreqTrackB5 proc ;ham ho tro bai 5 
                    ;hoat dong tuong tu thuat toan bai 3 
    push AX
    push BX
    push DX
    push CX
    push SI
    push DI
    
    xor SI, SI
    
    lea DI, freqTable
    mov CX, 128
    xor AL, AL
    rep stosb
    
    lea SI, string+2    ;bat dau tro duyet tu dau chuoi 

count_loop5:
    mov AL, [SI]        ;mov tung ky tu
    cmp AL, 0Dh
    je counted5
    
    xor AH, AH      
    lea DI, freqTable   ;tro DH den bang
    add DI, AX          ;chi ra vi tri
    inc BYTE PTR[DI]    ;tang chi so tan suat
    inc SI              ;SI++ -> duyet ky tu tiep theo
    jmp count_loop5

counted5:
    mov CX, 0           ;CX thanh ascii

saveTable5:
    lea DI, freqTable
    add DI, CX
    cmp BYTE PTR[DI], 0 ;tracking tan suat xuat hien
    je nextChar5
    
    push CX
    lea SI, string+2
    mov DI, 1

findPos5:
    mov AL, [SI]
    cmp AL, 0Dh
    je finPos5
    
    cmp AL, CL
    jne nextPos5
    
nextPos5:
    inc SI              ;SI++ -> duyet tang
    inc DI
    jmp finPos5              ;pop lai CX
    
finPos5:
    pop CX    
nextChar5:
    inc CX
    cmp CX, 128         ;kiem tra gioi han
    jl saveTable5
    
    pop DI               ;lam sach thanh ghi
    pop SI
    pop CX
    pop DX
    pop BX
    pop AX
    
    ret
subFreqTrackB5 endp    

END main
