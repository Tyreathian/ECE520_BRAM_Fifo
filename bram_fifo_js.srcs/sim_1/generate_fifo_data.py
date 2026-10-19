import os


def generate_fifo_data(filename="fifo_input_data.txt", loops=8):
    pattern = ["FFFF", "0000", "AAAA", "5555"]

    try:
        with open(filename, "w") as f:
            for i in range(loops):
                for word in pattern:
                    f.write(f"{word}\n")
        print(
            f"[SUCCESS] Generated {loops * len(pattern)} words of data in:\n{os.path.abspath(filename)}"
        )
    except IOError as e:
        print(f"[ERROR] Failed to write file: {e}")


if __name__ == "__main__":
    generate_fifo_data()
