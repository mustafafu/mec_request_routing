import sys
def get_max_from_lp(filename='./Output/greedy_output.txt',modepath='./semi_mip.mod',iter = 1):
    fp = open(filename,'r')
    data = fp.readlines()
    max_value = 0
    position = [-1,-1]
    flag = 0
    skipcount = 0
    for idx,line in enumerate(data):
        a = line.split()
        if idx<5 or len(a)!=10:
            skipcount += 1
            continue
        access = a
        for col,access_indicator in enumerate(access):
            if col == 0:
                continue
            access_indicator = float(access_indicator)
            if access_indicator !=1 and access_indicator> max_value:
                max_value = access_indicator
                position = [idx-skipcount+1,col]
                backup = access
        # access_indicator += access
    # data = np.loadtxt('D:/cmder/course/mec_request_routing/common_script/Output/greedy_output.txt', skiprows=6)
    # print(data)
    fp.close()

    if max_value==0:
        max_value = 'stop'
        return max_value
    else:
        sum_u = [float(i) for i in (backup)]



        fp1 = open(modepath,'a')
        if sum(sum_u[1:])<0.98:
            fp1.write('s.t. C' + str(iter) + ': access_indicator[' + str(position[1]) + ',' + str(
                position[0]) + '] = 0;\n')
            # for i in range(9):
            #     fp1.write('s.t. C' + str(iter)+'_'+str(i+1) + ': access_indicator[' + str(i+1) + ',' + str(position[0]) + '] = 0;\n')
        else:
            fp1.write('s.t. C'+str(iter)+': access_indicator['+str(position[1])+','+str(position[0])+'] = 1;\n')
        fp1.close()

    return max_value#return 0 means done

if __name__ == '__main__':

    flag = get_max_from_lp(iter = sys.argv[1])

#     print(max_value,position)
    exit(flag)
