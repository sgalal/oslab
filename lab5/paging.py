page_table = [1, 4, 3, 7]
print("Page Table Illustration\nPage table:", page_table)
page_num = int(input("Page number: "))
offset = int(input("Offset: "))
try:
  physical_addr = page_table[page_num];
except IndexError:
  print("Invalid index in page table.")
else:
  print("Physical Address: %d, Offset: %d" % (physical_addr, offset))
