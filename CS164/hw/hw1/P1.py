######
#  SubSequence: 2 ^ N
#     each letter can either show up or not, because there are n letters in
#     total, so the total number of possibilities is 2 ^ N
#
#  SubString: N + (N-1) + (N-2) + ... + 1 + 1= N(N+1) / 2 + 1
#     Empty String : 1
#     One letter: N
#     Two letters: N - 1
#     ....
#     N letters: 1
#
#     So the total is N*(N+1) / 2 + 1
#
######

def generateSubsequence(inputString, idx, cnt):
    if idx == len(inputString):
        print "SubSequence" + str(cnt[0]) + ":" + inputString
        cnt[0] += 1
        return
    generateSubsequence(inputString, idx + 1, cnt)
    pre = ""
    post = ""
    if idx > 0:
        pre = inputString[0:idx]
    if idx + 1 < len(inputString):
        post = inputString[idx + 1:]
    generateSubsequence(pre + post, idx, cnt)

def generateSubstring(inputString):
    print "SubString0:"
    cnt = 1
    for i in range(1, len(inputString) + 1):
        for j in range(0, len(inputString) - i + 1):
            print "SubString:" + str(cnt) + inputString[j: i + j]
            cnt += 1
def main():
    generateSubsequence("abcd", 0, [0])
    generateSubstring("abcd")

main()
