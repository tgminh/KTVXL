.model small 
.stack 100
.data
    note    DB 10,13, 'Chon bai (1-5): $' 
    note11  DB 10,13, 'Nhap chuoi: $'
    buffer  DB 50   ; chuoi dai max 50 ky tu
            DB ?    ; do dai thuc cua chuoi tai buffer+1
            DB 20 DUP('$')
    note12  DB 10,13, 'Chuoi da nhap: $'    
    note21  DB ' - pos $'
    brkln   DB 10,13, '$'
    
.code
main proc
    