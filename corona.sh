#! /bin/bash

export POSIXLY_CORRECT=yes
export LC_NUMERIC=en_US.UTF-8 

print_help()
{   
    echo "\033[1mcorona, a covid-19 infections log analyzer\033[0m"
    echo "Matyáš Strelec xstrel03, xstrel03@stud.fit.vutbr.cz"
    echo "v1.0, 2022/03/25"
    echo ""
    echo "\033[1mUsage: corona [-h] [FILTERS] [COMMAND] [LOG [LOG2 [...]]"
    echo ""
    echo "\033[1mCOMMAND\033[0m - specify the command, can be one of the following"
    echo ""
    echo "  \033[1minfected\033[0m  - count total number of infected persons"
    echo "  \033[1mmerge\033[0m     - merge multiple files into one, keep the original order"
    echo "  \033[1mgender\033[0m    - print number of infected for each gender"
    echo "  \033[1mage\033[0m       - print number of infected for each age group"
    echo "  \033[1mdaily\033[0m     - print number of infected for each day"
    echo "  \033[1mmonthly\033[0m   - print number of infected for each month"
    echo "  \033[1myearly\033[0m    - print number of infected for each year"
    echo "  \033[1mcountries\033[0m - print number of infected for each country (without CZ)"
    echo "  \033[1mdistricts\033[0m - print number of infected for each district"
    echo "  \033[1mregions\033[0m   - print number of infected for each region"
    echo ""
    echo "\033[1mFILTERS\033[0m - filter results, multiple filters can be used, each only once"
    echo ""
    echo "  \033[1m-a DATETIME\033[0m - after: use only records after the given date (including)"
    echo "              - \033[3mDATETIME\033[0m format is YYYY-MM-DD"
    echo ""
    echo "  \033[1m-a DATETIME\033[0m - before: use only records after the given date (including),"
    echo "              - \033[3mDATETIME\033[0m format is YYYY-MM-DD"
    echo ""
    echo "  \033[1m-g GENDER\033[0m   - use only records with the given gender"
    echo "              - \033[3mGENDER\033[0m can be \033[3mM\033[0m (men) or \033[3mZM\033[0m (women)"
    echo ""
    echo "  \033[1m-s [WIDTH]\033[0m  - when used with commands \033[3mgender, age, daily, monthly, yearly,\033[0m"
    echo "                \033[3mcountries, districts, regions\033[0m, print data graphically as a"
    echo "                histogram instead of numbers"
    echo "              - \033[3mWIDTH\033[0m is optional and specifies the length of the longest line,"
    echo "                if not given, default values are used."
    echo ""
    echo "\033[1m-h\033[0m      - print this help message"
    echo ""
}

ARGS=$#
RUN=""
COMMAND="none"
FILES="none"
USE_AFTER=0
AFTER_DATETIME="1970-01-01"
BEFORE_DATETIME="9999-99-99"
GENDER=""
USE_GRAPHIC=0
WIDTH=""
GENDER[0]="M"
GENDER[1]="Z"

# read command line arguments
while [ "$#" -gt 0 ];
do
    case "$1" in
        -h) 
            print_help
            exit 0
            ;;
        infected | merge | gender | age | daily | monthly | yearly | countries | districts | regions)
            COMMAND="$1"
            shift
            ;;
        -a)
            AFTER_DATETIME="$2"
            shift
            shift
            ;;
        -b)
            BEFORE_DATETIME="$2"
            shift
            shift
            ;;
        -g)
            if [ "$2" = "M" ]; 
            then
                GENDER[1]=""
            elif [ "$2" = "Z" ];
            then
                GENDER[0]=""
            fi
            shift
            shift
            ;;
        -s)
            USE_GRAPHIC=1
            WIDTH="$2"
            shift
            shift
            ;;
        *".csv")
            FILES="$1"
            shift
            ;;
        *)
            exit 0
    esac
done
              
RUN="tail -n +2 | awk -F, 'BEGIN { getline; print \$0 }
              { if (\$2 >= \"$AFTER_DATETIME\" && \$2 <= \"$BEFORE_DATETIME\" && (\$4 == \"${GENDER[0]}\" || \$4 == \"${GENDER[1]}\")) print \$0 }'"

if [ "$FILES" != "none" ];
then
    RUN="cat $FILES"
fi

# if [ $USE_GRAPHIC = 1 ];
# then
# fi

if [ "$COMMAND" = "none" ];
then
    printf "id,datum,vek,pohlavi,kraj_nuts_kod,okres_lau_kod,nakaza_v_zahranici,nakaza_zeme_csu_kod,reportovano_khs"
    eval "$RUN"
    exit 0
fi

case $COMMAND in
    infected)
        eval "$RUN | awk 'END{print NR}'"
        ;;
    merge)
        eval ""
        ;;
    gender)
        eval "$RUN | awk -F, 'BEGIN { M=0; Z=0} { if (\$4 == \"M\") M+=1 ; else if (\$4 == \"Z\") Z+=1} END { print \"M: \" M \"\\nZ: \" Z } '"
        ;;
    age)
        eval "$RUN | awk -F, '  BEGIN { ages[0]=0 ; ages[1]=0 ; ages[2]=0 ; ages[3]=0 ; ages[4]=0 ; ages[5]=0 ; ages[6]=0 ; ages[7]=0 ; ages[8]=0 ; ages[9]=0 ; ages[10]=0 ; ages[11]=0 ; ages[12]=0 ; }
                                            { if (\$3 >= 0 && \$3 <= 5) ages[0]+=1 ;
                                            else if (\$3 >= 6 && \$3 <= 15) ages[1]+=1 ;
                                            else if (\$3 >= 16 && \$3 <= 25) ages[2]+=1 ;
                                            else if (\$3 >= 26 && \$3 <= 35) ages[3]+=1 ;
                                            else if (\$3 >= 36 && \$3 <= 45) ages[4]+=1 ;
                                            else if (\$3 >= 46 && \$3 <= 55) ages[5]+=1 ;
                                            else if (\$3 >= 56 && \$3 <= 65) ages[6]+=1 ;
                                            else if (\$3 >= 66 && \$3 <= 75) ages[7]+=1 ;
                                            else if (\$3 >= 76 && \$3 <= 85) ages[8]+=1 ;
                                            else if (\$3 >= 86 && \$3 <= 95) ages[9]+=1 ;
                                            else if (\$3 >= 96 && \$3 <= 105) ages[10]+=1 ;
                                            else if (\$3 >= 106) ages[11]+=1 ;
                                            else if (\$3 == \"\") ages[12]+=1 ;
                                            }
                                            END {
                                            print \"0-5   : \" ages[0] ;
                                            print \"6-15  : \" ages[1] ;
                                            print \"16-25 : \" ages[2] ;
                                            print \"26-35 : \" ages[4] ;
                                            print \"36-45 : \" ages[5] ;
                                            print \"46-55 : \" ages[6] ;
                                            print \"56-65 : \" ages[7] ;
                                            print \"66-75 : \" ages[8] ;
                                            print \"76-85 : \" ages[9] ;
                                            print \"86-95 : \" ages[10] ;
                                            print \"96-105: \" ages[11] ;   
                                            print \">105  : \" ages[11] ;        
                                            if (ages[12] != 0) print \"None  : \" ages[12] ;                                                                                     
                                            }'"
        ;;
    daily)
        eval "$RUN | awk -F, '{ print \$2 }' | uniq -c | awk -F' ' '{ print \$2 \": \" \$1 }'"
        ;;
    monthly)
        eval "$RUN | awk -F, '{ print \$2 }' | cut -c -7 | uniq -c | awk -F' ' '{ print \$2 \": \" \$1 }'"
        ;;
    yearly)
        eval "$RUN | awk -F, '{ print \$2 }' | cut -c -4 | uniq -c | awk -F' ' '{ print \$2 \": \" \$1 }'"
        ;;
    countries)
        eval "$RUN | awk -F, '{ if (\$8 != \"\") print \$8 }' | sort | uniq -c | awk -F' ' '{ print \$2 \": \" \$1 }'"
        ;;
    districts)
        eval "$RUN | awk -F, '{ print \$6 }' | sort | uniq -c | awk -F' ' '{ if ( \$2 == \"\" ) none=\$1; else print \$2 \": \" \$1 } END { if (none != 0) print \"None: \"none }'"
        ;;
    regions)
        eval "$RUN | awk -F, '{ print \$5 }' | sort | uniq -c | awk -F' ' '{ if ( \$2 == \"\" ) none=\$1; else print \$2 \": \" \$1 } END { if (none != 0) print \"None: \"none }'"
        ;;
esac
