import sys
import numpy as np

#
# import argparse
#
# parser = argparse.ArgumentParser()
# parser.add_argument('iter',type=int,default=2)
# parser.add_argument('zero_constraint',type=int,default=5)
# parser.add_argument('threshold',type=float,default=0.8)
# args = parser.parse_args()

# iter=sys.argv[1],zero_constraint=sys.argv[2],threshold=sys.argv[3] scenario_number=sys.agrv[4]

def fix_one(filename, modepath, scenario_number):
    fp_fixone_log = open('./fixone_log/log_' + str(scenario_number) + '.txt', 'w')
    fp2 = open(filename, 'r')
    fp_fixone = open(modepath, 'a')
    data = fp2.readlines()
    max_value = 0
    position = [-1, -1]
    flag = 0
    skipcount = 0
    did_i_find_dotdot = 0
    for idx, line in enumerate(data):
        a = line.split()
        if a[0] == ':':
            did_i_find_dotdot = 1
            skipcount += 1
            continue

        if did_i_find_dotdot == 0:
            skipcount += 1
            continue

        if a[0] == ';':
            break

        access = a
        for col, access_indicator in enumerate(access):
            if col == 0:
                continue
            access_indicator = float(access_indicator)
            if access_indicator == 1:
                position = [idx - skipcount + 1, col]
                fp_fixone.write(
                    's.t. C_fixone_init' + str(position[0]) + str(position[1]) + ': access_indicator[' + str(position[1])
                    + ',' + str(position[0]) + '] = 1;\n')
                fp_fixone_log.write(str(position[0]) + '    ' + str(position[1]) +',')
    fp2.close()
    fp_fixone_log.close()
    fp_fixone.close()



def fix_zero(filename, modepath):
    fp2 = open(filename, 'r')
    fp_fixzero = open(modepath, 'a')
    data = fp2.readlines()
    max_value = 0
    position = [-1, -1]
    flag = 0
    skipcount = 0
    user_sum = 0
    did_i_find_dotdot = 0
    for idx, line in enumerate(data):
        a = line.split()

        if a[0] == ':':
            did_i_find_dotdot = 1
            skipcount += 1
            continue

        if did_i_find_dotdot == 0:
            skipcount += 1
            continue

        if a[0] == ';':
            break

        access = a
        for col, access_indicator in enumerate(access):
            if col == 0:
                continue
            access_indicator = float(access_indicator)
            user_sum += access_indicator
        # print(user_sum)
        if user_sum < 1:
            #   print('****')

            position = [idx - skipcount + 1, col]
            fp_fixzero.write(
                's.t. C_fixzero' + str(position[0]) + str(
                    position[1]) + ' : sum {n in Nodes} access_indicator[n,' + str(
                    position[0]) + '] = 0;\n')
        user_sum = 0
    fp2.close()
    fp_fixzero.close()


def get_max_from_lp(filename='./Output/greedy_output.txt', modepath='./semi_mip.mod', iter='0', zero_constraint='5',
                    threshold='0.8',scenario_number = '169'):

    threshold = float(threshold)
    iter = str(iter)
    scenario_number = int(scenario_number)
    # zero_constraint+=1
    # print(zero_constraint)
    if iter == '0':
        fix_one(filename, modepath,scenario_number)
        # return 'init'
    if zero_constraint == '2':
        fix_zero(filename, modepath)
        return 'stop'
    fp = open(filename, 'r')
    fp_fixone_logr = open('./fixone_log/log_' + str(scenario_number) + '.txt', 'r')

    fp1 = open(modepath, 'a')
    one_log = fp_fixone_logr.read()
    one_log = one_log.split(',')
    fp_fixone_logr.close()
    data = fp.readlines()
    max_value = 0
    position = [-1, -1]
    flag = 0
    skipcount = 0

    did_i_find_dotdot = 0
    for idx, line in enumerate(data):
        a = line.split()

        if a[0] == ':':
            did_i_find_dotdot = 1
            skipcount += 1
            continue

        if did_i_find_dotdot == 0:
            skipcount += 1
            continue

        if a[0] == ';':
            break

        access = a
        sum_u = [float(i) for i in (a)]
        for col, access_indicator in enumerate(access):
            if col == 0:
                continue
            access_indicator = float(access_indicator)
            if access_indicator == 1:
                position_1 = [idx - skipcount + 1, col]
                current_one = str(position_1[0]) + '    ' + str(position_1[1])
                #----------- if new 1 shows, fix it and return
                if current_one not in one_log:
                    fp_fixone_log = open('./fixone_log/log_' + str(scenario_number) + '.txt', 'a')
                    fp1.write(
                        's.t. C_fixone_update' + str(position_1[0]) + str(position_1[1]) + ': access_indicator[' + str(position_1[1])
                        + ',' + str(position_1[0]) + '] = 1;\n')
                    fp_fixone_log.write(str(position_1[0]) + '    ' + str(position_1[1]) +',')
                    fp_fixone_log.close()
                    # return 'fixone'





            if access_indicator != 1 and access_indicator > max_value:
                max_value = access_indicator
                position = [idx - skipcount + 1, col]
                backup = access#backup is the row who has max_value
                # print(position,max_value)
        # access_indicator += access
    # data = np.loadtxt('D:/cmder/course/mec_request_routing/common_script/Output/greedy_output.txt', skiprows=6)
    # print(data)
    fp.close()
    # print(position,max_value)


    if max_value == 0:
        max_value = 'stop'
        return max_value
    else:
        sum_u = [float(i) for i in (backup)]
        
#———————————drop off sum_u < 1 because they are either less profits or node can not host this user compelete
        if sum(sum_u[1:]) < threshold:
            # fp1.write('s.t. C' + str(iter) + ': access_indicator[' + str(position[1]) + ',' + str(
            #     position[0]) + '] = 0;\n')
            # for i in range(9):
            #     fp1.write('s.t. C' + str(iter)+'_'+str(i+1) + ': access_indicator[' + str(i+1) + ',' + str(position[0]) + '] = 0;\n')
            fp1.write('s.t. access_constraint_dropoff' + str(iter) + ' : sum {n in Nodes} access_indicator[n,' + str(
                position[0]) + '] = 0;\n')
            max_value = 'sum' + str(sum_u[1:]) + 'max ' + str(max_value)

        else:
#_________set the min in the max_value row to zero
            sum_u_array = np.asarray(sum_u)
# np.min(a[np.nonzero(a)])
            min_of_maxu = np.min(sum_u_array[np.nonzero(sum_u_array)])#min except zero
            min_col = sum_u.index(min_of_maxu)

            # print(min_col,position)
            fp1.write(
                's.t. C' + str(iter) + ': access_indicator[' + str(min_col) + ',' + str(position[0]) + '] = 0;\n')
            # fp1.write(
            #     's.t. C' + str(iter) + ': access_indicator[' + str(position[1]) + ',' + str(position[0]) + '] = 1;\n')
        fp1.close()

    return max_value  # return 0 means done


if __name__ == '__main__':
    # flag = get_max_from_lp( iter=args.iter,
    #                        zero_constraint=args.zero_constraint, threshold=args.threshold,
    #                         filename='./Output/greedy_output.txt', modepath='./semi_mip.mod')
    scenario_number = sys.argv[4]
    # scenario_number = '7'
    inner_iter = sys.argv[1]
    # inner_iter = '1'
    modepath_string = './iter_models/semi_mip_' + str(scenario_number) + '.mod'
    filename_string = '../Output/greedy_output_' + str(scenario_number) + '_' + str(inner_iter) + '.txt'
    # flag = get_max_from_lp(filename=filename_string, modepath=modepath_string)
    flag = get_max_from_lp(filename=filename_string, modepath=modepath_string, iter=sys.argv[1],
                           zero_constraint=sys.argv[2], threshold=sys.argv[3],scenario_number = sys.argv[4])

    #     print(max_value,position)
    exit(flag)
