// provided by: paule32
// MIT licence!
#include <QCoreApplication>
#include <QString>

#include <QDebug>

const int precision = 10;
bool minus_flag = false;

QChar lhs_op;  // left  hand value operator
QChar rhs_op;  // right hand value operator

QString reverse(QString str)
{
    QString rev;
    QChar   c;
    int     len = str.length();
    for (int i = 0; i < len; ++i) {
        c = str.at(len-i-1);
        rev.append(c);
    }
    return rev;
}

// addition || subtraction
QString addORsub(QString lhs, QString rhs)
{
    QString nr;
    int p1, p2, p6 = 0;

    // check for comma...
    int cpos1 = 0;
    int cpos2 = 0;
    int cpos;
    
    if (lhs.contains(QChar('.'))) cpos1 = lhs.indexOf(QChar('.'));
    if (rhs.contains(QChar('.'))) cpos2 = rhs.indexOf(QChar('.'));

    QLatin1Char nullchar =
    QLatin1Char('0');
    
    if (cpos1 < cpos2) {
        cpos = cpos2 - cpos1;
        for (int i = 0; i < cpos; ++i) {
            lhs = lhs.insert(0,nullchar);
            rhs = rhs.append(nullchar);
        }
    }
    else if (cpos1 > cpos2) {
        cpos = cpos1 - cpos2;
        for (int i = 0; i < cpos; ++i) {
            rhs = rhs.insert(0,nullchar);
            lhs = lhs.append(nullchar);
        }
    }
    
    for (int p = 0; p < precision; ++p)
    {
        if (p >= lhs.size()) break;
        
        if (lhs.toLatin1().at(p) == '.'
        ||  rhs.toLatin1().at(p) == '.') {
            nr.append(QLatin1Char('.'));
            continue;
        }
        
        QChar c1 = lhs.toLatin1().at(p);
        QChar c2 = rhs.toLatin1().at(p);
        
        if (!c1.isDigit() || !c2.isDigit()) {
            qDebug() << "Error: char not digit.";
            exit(1);
        }
        
        p1 = QString(c1).toInt();
        p2 = QString(c2).toInt();
       
        if((lhs_op == '+' && rhs_op == '+')
        || (lhs_op == '-' && rhs_op == '-'))
        {
            p1 = p1 + p2;
            if (p1 == 0) {
                nr.append(QString::number(0));
                p6 = 0;
            }
            else if (p1 == 10) {
                nr.append(QString::number(0));
                p6 = 1;
            }
            else if (p1 > 10) {
                p1 = p1 + p6 - 10;
                p6 = 1;
                nr.append(QString::number(p1));
            }
            else if (p1 < 10) {
                p1 = p1 + p6;
                p6 = 0;
                nr.append(QString::number(p1));
            }
            
            if (lhs_op == '+' && rhs_op == '+') minus_flag = false; else
            if (lhs_op == '-' && rhs_op == '-') minus_flag = true ;
        }
        else
        if((lhs_op == '+' && rhs_op == '-')
        || (lhs_op == '-' && rhs_op == '+'))
        {
            if (p1 == 0 && p2 > 0) {
                minus_flag = false;
                if (p6 < -100)
                break;
                p1 = -(0 - p2 - p6);
                nr.append(QString::number(p1));
            }
            else if (p1 > 0 && p2 == 0) {
                p1 = -(p1 - 10) - p6;
                p6 = -1;
                if (p1 > 0) {
                    minus_flag = false;
                    nr.append(QString::number(p1));
                }
            }
            else if (p1 > 0 && p2 > 0) {
                if (lhs_op == '-' && rhs_op == '+')
                p1 = -p1 + p2 + p6; else
                p1 = -p2 + p1;
                if (p1 > 0) {
                    minus_flag = false;
                    p6 = 0;
                    nr.append(QString::number(p1));
                }
                else if (p1 < 0) {
                    minus_flag = true;
                    p1 = -p1;
                    p1 = (((10 + p6) - p1) + p1);
                    p6 = -101;
                    nr.append(QString::number(p1));
                }
            }
        }
    }
    
    nr = reverse(nr);
    nr.remove(QRegExp("^[0]*"));
    
    if (nr.trimmed().length() < 1)
    nr = "0";

    if (minus_flag == true)
    nr = nr.insert(0,"-");
    
    return nr;
}

// multiplication
QString mul(QString lhs, QString rhs)
{

}

QString getMathOperation(QString lhs, QString rhs)
{
    QString n1 = reverse(lhs);
    QString n2 = reverse(rhs);

    lhs_op = '+'; if (n1.contains("-")) lhs_op = '-';
    rhs_op = '+'; if (n2.contains("-")) rhs_op = '-';

    n1 = n1.remove(QRegExp("[+-]*"));
    n2 = n2.remove(QRegExp("[+-]*"));
    
    if (lhs_op == '+' || rhs_op == '+') return addORsub(n1,n2);
    if (lhs_op == '-' || rhs_op == '-') return addORsub(n1,n2);
}

QString add(QString lhs, QString rhs) { return getMathOperation(lhs, rhs); }
QString sub(QString lhs, QString rhs) { return getMathOperation(lhs, rhs); }

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    
    QString lhs_res, lhs_num = "-201.264";
    QString rhs_res, rhs_num = "1120.99";
    
    lhs_res = lhs_num.rightJustified(precision, '0');
    rhs_res = rhs_num.rightJustified(precision, '0');
    
    qDebug() << "=" << sub(lhs_res, rhs_res);
    return a.exec();
}
