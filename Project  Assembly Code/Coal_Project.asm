; Car Rental System in MASM32

.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib

.data
TOTAL_CARS equ 12

car1 db "Toyota Corolla", 0
car2 db "Honda Civic", 0
car3 db "Suzuki Swift", 0
car4 db "Toyota Hilux", 0
car5 db "Honda City", 0
car6 db "Suzuki Cultus", 0
car7 db "Toyota Fortuner", 0
car8 db "Honda BR-V", 0
car9 db "Suzuki Alto", 0
car10 db "Toyota Yaris", 0
car11 db "Honda Accord", 0
car12 db "Suzuki Wagon R", 0

car_total_qty db 3, 2, 4, 2, 3, 5, 1, 2, 6, 3, 2, 4
car_rented_qty db 12 dup(0)
car_rent db 50, 60, 40, 70, 55, 35, 90, 65, 30, 52, 75, 38

welcomeMsg db "=== WELCOME TO CAR RENTAL SYSTEM ===", 13,10,13,10,0
menuOptions db 13,10,13,10
            db "1. Rent a Car", 13,10
            db "2. Return a Car", 13,10
            db "3. View Available Cars", 13,10
            db "4. View Rented Cars", 13,10
            db "5. Exit", 13,10,13,10
            db "Enter your choice (1-5): ", 0

availableCars db 13,10,"AVAILABLE CARS:", 13,10,0
rentedCars db 13,10,"RENTED CARS:", 13,10,0
returnedCarsMsg db 13,10,"CARS AVAILABLE FOR RETURN:", 13,10,0
chooseCar db 13,10,"Enter car number (1-12): ", 0
enterQuantity db "Enter quantity to rent (1-9): ", 0
enterReturnQuantity db "Enter quantity to return car (1-9): ", 0
enterDays db "Enter number of rental days (1-30): ", 0
rentSuccess db 13,10,"Car(s) rented successfully!", 13,10,0
returnSuccess db 13,10,"Car(s) returned successfully!", 13,10,0
totalCost db "Total Cost: $", 0
invalidChoice db 13,10,"Invalid choice! Try again.", 13,10,0
noCars db 13,10,"No cars available!", 13,10,0
noRented db 13,10,"No cars are currently rented.", 13,10,0
pressAnyKey db 13,10,"Press any key to continue...", 0
exitMsg db 13,10,"Thank you for using Car Rental System!", 13,10,0
notEnoughQty db 13,10,"Not enough quantity available!", 13,10,0

qty_available db " - Available: ", 0
qty_rented db " - Rented: ", 0
rate_str db " (Rate: $", 0
per_day db "/day)", 13,10,0
newline db 13,10,0

input_buffer db 10 dup(0)
temp_buffer db 10 dup(0)
num_buffer db 10 dup(0)

.code

num_to_str proc number:DWORD, buffer:DWORD
    push eax
    push ebx
    push ecx
    push edx
    push edi
    push esi
    
    mov eax, number
    mov edi, buffer
    mov ecx, 0
    
    cmp eax, 0
    jne start_convert
    mov byte ptr [edi], '0'
    mov byte ptr [edi+1], 0
    jmp convert_exit
    
start_convert:
    mov esi, edi
    
digit_loop:
    cmp eax, 0
    je reverse_digits
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, '0'
    mov byte ptr [esi], dl
    inc esi
    inc ecx
    jmp digit_loop
    
reverse_digits:
    mov byte ptr [esi], 0
    dec esi
    mov edi, buffer
    
reverse_loop:
    cmp edi, esi
    jge convert_exit
    
    mov al, byte ptr [edi]
    mov bl, byte ptr [esi]
    mov byte ptr [edi], bl
    mov byte ptr [esi], al
    
    inc edi
    dec esi
    jmp reverse_loop
    
convert_exit:
    pop esi
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
num_to_str endp

get_car_name proc uses ebx, index:DWORD
    mov ebx, index
    cmp ebx, 0
    je ret_car1
    cmp ebx, 1
    je ret_car2
    cmp ebx, 2
    je ret_car3
    cmp ebx, 3
    je ret_car4
    cmp ebx, 4
    je ret_car5
    cmp ebx, 5
    je ret_car6
    cmp ebx, 6
    je ret_car7
    cmp ebx, 7
    je ret_car8
    cmp ebx, 8
    je ret_car9
    cmp ebx, 9
    je ret_car10
    cmp ebx, 10
    je ret_car11
    mov eax, offset car12
    ret
ret_car1: mov eax, offset car1
    ret
ret_car2: mov eax, offset car2
    ret
ret_car3: mov eax, offset car3
    ret
ret_car4: mov eax, offset car4
    ret
ret_car5: mov eax, offset car5
    ret
ret_car6: mov eax, offset car6
    ret
ret_car7: mov eax, offset car7
    ret
ret_car8: mov eax, offset car8
    ret
ret_car9: mov eax, offset car9
    ret
ret_car10: mov eax, offset car10
    ret
ret_car11: mov eax, offset car11
    ret
get_car_name endp

display_car proc uses esi edi, index:DWORD
    mov esi, index
    
    mov eax, esi
    inc eax
    invoke num_to_str, eax, addr temp_buffer
    invoke StdOut, addr temp_buffer
    mov byte ptr [temp_buffer], '.'
    mov byte ptr [temp_buffer+1], ' '
    mov byte ptr [temp_buffer+2], 0
    invoke StdOut, addr temp_buffer
    
    invoke get_car_name, esi
    invoke StdOut, eax
    
    invoke StdOut, addr rate_str
    movzx eax, car_rent[esi]
    invoke num_to_str, eax, addr num_buffer
    invoke StdOut, addr num_buffer
    invoke StdOut, addr per_day
    
    invoke StdOut, addr qty_available
    movzx eax, car_total_qty[esi]
    movzx ebx, car_rented_qty[esi]
    sub eax, ebx
    invoke num_to_str, eax, addr num_buffer
    invoke StdOut, addr num_buffer
    
    invoke StdOut, addr qty_rented
    movzx eax, car_rented_qty[esi]
    invoke num_to_str, eax, addr num_buffer
    invoke StdOut, addr num_buffer
    invoke StdOut, addr newline
    
    ret
display_car endp

display_available_cars proc uses ecx esi
    invoke StdOut, addr availableCars
    
    mov ecx, TOTAL_CARS
    mov esi, 0
    
display_loop:
    push ecx
    
    movzx eax, car_total_qty[esi]
    movzx ebx, car_rented_qty[esi]
    cmp eax, ebx
    je skip_this_car
    
    invoke display_car, esi
    
skip_this_car:
    inc esi
    pop ecx
    loop display_loop
    ret
display_available_cars endp

display_rented_cars proc uses ecx esi edx
    invoke StdOut, addr rentedCars
    
    mov ecx, TOTAL_CARS
    mov esi, 0
    mov edx, 0
    
rented_loop:
    push ecx
    
    cmp car_rented_qty[esi], 0
    je skip_rented
    
    invoke display_car, esi
    inc edx
    
skip_rented:
    inc esi
    pop ecx
    loop rented_loop
    
    cmp edx, 0
    jne has_rented
    invoke StdOut, addr noRented
    
has_rented:
    ret
display_rented_cars endp

display_returnable_cars proc uses ecx esi edx
    invoke StdOut, addr returnedCarsMsg
    
    mov ecx, TOTAL_CARS
    mov esi, 0
    mov edx, 0
    
returnable_loop:
    push ecx
    
    cmp car_rented_qty[esi], 0
    je skip_returnable
    
    invoke display_car, esi
    inc edx
    
skip_returnable:
    inc esi
    pop ecx
    loop returnable_loop
    
    cmp edx, 0
    jne has_returnable
    invoke StdOut, addr noRented
    
has_returnable:
    ret
display_returnable_cars endp

get_number proc uses esi edi, prompt:DWORD, min_val:DWORD, max_val:DWORD
get_input:
    invoke StdOut, prompt
    invoke StdIn, addr temp_buffer, 10
    
    mov esi, offset temp_buffer
    xor eax, eax
    xor ecx, ecx
    
convert_digit:
    mov cl, byte ptr [esi]
    cmp cl, 0
    je convert_done
    cmp cl, 13
    je convert_done
    cmp cl, 10
    je convert_done
    cmp cl, '0'
    jb invalid_number
    cmp cl, '9'
    ja invalid_number
    
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp convert_digit
    
invalid_number:
    invoke StdOut, addr invalidChoice
    jmp get_input
    
convert_done:
    cmp eax, min_val
    jb range_error
    cmp eax, max_val
    ja range_error
    ret
    
range_error:
    invoke StdOut, addr invalidChoice
    jmp get_input
get_number endp

rent_car_function proc uses esi edi ebx edx
    local qty_to_rent:DWORD
    local days_to_rent:DWORD
    local car_index:DWORD
    local total_price:DWORD
    
    call display_available_cars
    
    invoke get_number, addr chooseCar, 1, 12
    dec eax
    mov car_index, eax
    mov esi, eax
    
    movzx eax, car_total_qty[esi]
    movzx ebx, car_rented_qty[esi]
    cmp eax, ebx
    je no_qty_available
    
    invoke get_number, addr enterQuantity, 1, 9
    mov qty_to_rent, eax
    
    mov esi, car_index
    movzx eax, car_total_qty[esi]
    movzx ebx, car_rented_qty[esi]
    sub eax, ebx
    cmp qty_to_rent, eax
    ja not_enough
    
    invoke get_number, addr enterDays, 1, 30
    mov days_to_rent, eax
    
    mov esi, car_index
    mov eax, qty_to_rent
    add car_rented_qty[esi], al
    
    mov esi, car_index
    xor eax, eax
    mov al, byte ptr car_rent[esi]
    
    mov ecx, eax
    
    mov eax, qty_to_rent
    
    imul eax, ecx
    
    mov ebx, days_to_rent
    imul eax, ebx
    
    mov total_price, eax
    
    invoke StdOut, addr rentSuccess
    invoke StdOut, addr totalCost
    invoke num_to_str, total_price, addr num_buffer
    invoke StdOut, addr num_buffer
    invoke StdOut, addr newline
    ret
    
no_qty_available:
    invoke StdOut, addr noCars
    ret
    
not_enough:
    invoke StdOut, addr notEnoughQty
    ret
rent_car_function endp

return_car_function proc uses esi edi
    local qty_to_return:DWORD
    local car_index:DWORD
    
    call display_returnable_cars
    
    invoke get_number, addr chooseCar, 1, 12
    dec eax
    mov car_index, eax
    mov esi, eax
    
    cmp car_rented_qty[esi], 0
    je no_rented_cars
    
    invoke get_number, addr enterReturnQuantity, 1, 9
    mov qty_to_return, eax
    
    mov esi, car_index
    movzx ecx, car_rented_qty[esi]
    cmp qty_to_return, ecx
    ja invalid_return_qty
    
    mov eax, qty_to_return
    sub car_rented_qty[esi], al
    invoke StdOut, addr returnSuccess
    ret
    
invalid_return_qty:
    invoke StdOut, addr invalidChoice
    ret
    
no_rented_cars:
    invoke StdOut, addr noRented
    ret
return_car_function endp

view_available_function proc
    call display_available_cars
    ret
view_available_function endp

view_rented_function proc
    call display_rented_cars
    ret
view_rented_function endp

start:
    invoke StdOut, addr welcomeMsg

main_menu:
    invoke StdOut, addr menuOptions
    invoke StdIn, addr input_buffer, 10
    
    cmp input_buffer[0], '1'
    je option1
    cmp input_buffer[0], '2'
    je option2
    cmp input_buffer[0], '3'
    je option3
    cmp input_buffer[0], '4'
    je option4
    cmp input_buffer[0], '5'
    je option5
    
    invoke StdOut, addr invalidChoice
    jmp main_menu

option1:
    call rent_car_function
    jmp continue_menu

option2:
    call return_car_function
    jmp continue_menu

option3:
    call view_available_function
    jmp continue_menu

option4:
    call view_rented_function
    jmp continue_menu

option5:
    jmp exit_program

continue_menu:
    invoke StdOut, addr pressAnyKey
    invoke StdIn, addr input_buffer, 10
    jmp main_menu

exit_program:
    invoke StdOut, addr exitMsg
    invoke ExitProcess, 0

end start