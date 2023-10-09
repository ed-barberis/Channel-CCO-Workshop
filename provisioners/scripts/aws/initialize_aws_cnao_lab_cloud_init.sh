#!/bin/sh -eux
# appdynamics aws cnao lab cloud-init script to initialize aws ec2 instance launched from ami.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] aws user and host name config parameters [w/ defaults].
user_name="${user_name:-ec2-user}"
aws_ec2_hostname="${aws_ec2_hostname:-cnao-lab-vm}"
aws_ec2_domain="${aws_ec2_domain:-localdomain}"
aws_region_name="${aws_region_name:-us-east-2}"
use_aws_ec2_num_suffix="${use_aws_ec2_num_suffix:-true}"
aws_eks_cluster_name="${aws_eks_cluster_name:-CNAO-Lab-01-abcde-EKS}"
cnao_k8s_apm_name="${cnao_k8s_apm_name:-cnao-lab-01-abcde-eks}"
cnao_lab_id="${cnao_lab_id:-cnao-lab-01-abcde}"
lab_number="${lab_number:-1}"

# configure public keys for specified user. --------------------------------------------------------
user_home=$(eval echo "~${user_name}")
user_authorized_keys_file="${user_home}/.ssh/authorized_keys"
user_key_name="Channel-CNAO-Workshop"
user_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkVnb7a69d+MSRG08WdqfvWXEpnT544XzohdZ0sIs5fRLU+pAh48F+BieIqxvCUKIUDXQFP04iQmoo5MKiLH42YVfDmsoidLDejiDS0O5KTn8DS6jA2akeT19xpYweKmRcw4kz+DeBe9dmYmggGQYZx48bSwBrwHcjvJciYTbLyBxmTx/kUIfn4Ub81cfoKq/m5qh/LnyZsXo+ZWj6kGDWsqSpX3I0jysaEsvQDRoRUUe0gSPIe7Y3IfTLsCj0PxzFMDqASeHMMGGoBzMhdWXexiDCUIcToGRKTC6FVfDEZs1kTYKJe7hp0CJtZHMdM7yAhb1JSAURT6ZcOwopxIH7 Channel-CNAO-Workshop"

# 'grep' to see if the user's public key is already present, if not, append to the file.
grep -qF "${user_key_name}" ${user_authorized_keys_file} || echo "${user_public_key}" >> ${user_authorized_keys_file}
chmod 600 ${user_authorized_keys_file}

# public keys from appdynamics channel sales team accounts for ed barberis.
aws_cloud9_public_key_01="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDOCEHU0ygOHaI7u6F3AUFbjJuB6+urympwYHcwyWRArCse9ZIHdPltaNuUbxYvAWxwG+gSviy28BZlwDOOLCD3VEVexdDFpEh2qBzEf+OaVh9kwlNqBPoHaZL7cTbsRb5vlFWK/01jUgKnI2jathARN4/sn56neJ36KpfMfCwtOjpBYzjQ9nIVEC9m5ZAOdCtPdh+Lco1IgL2ug2qP9273oflSYw90sCw9znuYjowOsigAilhGlenLZYeql/s5QjGlffrke2w0z9Ux7Tr6EULDJHs1JgfLsLmk2kuOq3C9706CIjyQyecRfgPyHTVfPBzXjButJKHTFl6awc14MQuT0wF7DFe2wQGmhFG93FXNHg87BYnH88fWMpeUcI1Agr6GV46nmPJpR+h+adaZSDphe/3RUsSoiXENXZB4ASYAyK1xhFlQxgbk3s/JlLlht6l1HMvYbw/FFi9VlIbaAlJH3+qeOEgzsRzTm1S20VRgPxtQX+Hw3NTOGfxcwE9XyAPAndc6mPSJ7Vtg+36PauLZgQ5M8TEotpjtBDGXAjpAOz7k0S5nKVyrUD5+X14QLXTF9KmcdQx8fv1F1N6zMLT39cNJxpXskmwwovE4JcB2X/scx60Ae/R0ELC3e/r9R3L964yosTmrPWD70ken20pGJSG4FuZOk9wT3SDfGQxTqQ== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_02="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCauKkcd0elSHLJD2ViHuhKcROo5yvFuvmIcsyvFJSi930w8LdIYaqgq5MGhDkQl5ZBBQvDRJNyq1UsvjPPNd/C5PPlQw1kxYv2MSyVClvlxB86ndRFV5pCkMzuff7sI/rDlI5Za4UeLim2BMYswc7mt2wxsJDyPJFazlU1W+D/zCSG+Yb6SYu5YXU4CSdAUTrbhYkACad8FdJDJHrlAscZJ4XAgnm+kFXhjKsUkOKksjiJQPNMg5f1eQfrBySxWtiU9J6Jbd+w89zNuTMuLcZDEU3G+1uq3RMerezvuL6ZZ6aTddlNT4jmBWYSpz040g/sscV+SctXORBRexjGQF4b9AZOlGmCB4eRvpNhtnsgjNbY1l8RrQDV9IJyJc+Ys9YO+EhpjoMmHvkmMeUiQMkh3SPimribaA2TJ4U4p8R2W5WQSOksAz3AXE7EZRSRY9+CfSRzv3ywgJafnXCY2GwLWYPeYku5Jko0JKT991pxNTctU0NChcjhI/UFviuZNIZsG8IP44RBwd4k0CXbxVeKpzJLSzxaNQsNkdgn/QeL0lEXDBIXWAO1U/dYL5BMl0HLx/Vjc1Vh041+roBHiP5E3IgMNLKBZHmfMtDXkgv7NL4zi/4Om0v+QSOPns5JQIAWQ92HmooCHq0rIg29sItN4+4q6Xc7GV3nHYcoNTtBnw== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_03="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXAgvFPH5MJa0P2EUKpv4ydb8INyyF/oTR8+gyOgutCd7CLUO8Bv1C1gR6cl1zbFwBriiMZ7g1zWJCjFOWrbfOXEDOR1FZ/16Pn4obUVVRkkJngqQlCKef5GVZvXTdTRd7tr6o5aBhooZKkbLzggAy/Ex1o+6wWT36oziCJQGk65mrZbvj2ABpeJsxh/FZDesCHXSYnnAeHsUZg9sD84MpC6hV7PROW2TOktWueUDxZ9XtsUFobdUF1nWT6TyTal2/VA6rvCZ+1L7/3caYJ+yHb5bqT//hOXIiHRt+ICo+nvovt99ubFtlgJ5sOf+TZgLl3TgB+oPS9xbf6l1hw7BJYyvD0fUiqoibM6nR7QtUCC7g+zVHYZhKsOeJYUpRFYiWTOTPkxMZ3zNbdhg27Iys3czMoWeF3LxWsIrKB8jAfJC7RE5cvnEF259bfwW4LpzJtL5DflhnRI/hBvgiAApTyJYr+qnfXfWoswTtsk4TeeZzccoYQhshbTXXYPq3YxZfPSu3GQrT9VnF6AjC6cTGH30n1SmqYj43V6RNzw78xbcmUuaEoxIfWgT4LXMEjQ5QMScFKpDctfqocIxQ1e6PYs9roUNIpKxqw+sHPblRVWMKAExBywgCPmGZXBkgo3EPjhBe0Rgz2bPIABuZ7ML9CH1dvyCt+OhzVDRN9P2Nww== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_04="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsHaeJCYJWEfuYw3Os2MJARG5KlbIuC/vXBkRQ8F8Ap4/WVKMmErDMzyxVXkIv7pcWPWwZFpEyVQhq/yIRce4KBu4ZHJy4+4tXLXLgYmufGfz7v8Ekx7yOD/G9kXB9+tq7xQj8uzl1mb606E3E0ZwCQIv/a6olaT/WQGe6RDpQAjCBlLTTT8JHKV0oUyjrEBrr0KO7SWZmAujFWDGk5s7vuDn5GOyHu61FFthOlmGMDVyjFTN9vYbSqVC0eyQDmKiUB84fIkXuyqQCnWZkWaCm3RctLukshJLjp/Hsix6im2cYHq1s4/pf0HnI+UEjgskr6vV0iz0B1cBjsYAMjT18nsnyiTyLIYaF+wuPbmAlFo606wfTGaB3jv64o99AIyv5/iPNW1q6p7JK8MbCF/O0Cyd9LOMt5Sccw6xMlQf6J85U/GFyGlsQfp4cu1cxpLo9bGebkAeVsv/I/aUYA9sOKjgJENzQ7dlsmMuoLrCelfPKCGfR6aN+yjZCkHusQddZkeK8eYOh3gVWtzqzc+SYtyW05wbFD1D7UBnqgaSca8wO+lTTMHP0Flf7MS0QeLXpV5WKlTEUoaFW1L5dFFGf6wgVzHTboeOEQhh51mJ+B5lQSGxg1x+00Rw2ZuB4AWlLjdNt5XD+2p41Ik1Xhhxw6aNDkwuHOqAwWpIR59K6Lw== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_05="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4QPtzmOAkDHmLDhaG7E7mDTPBk8KIkCjir/Y6ETIu1+bT1YCOeHJcmc3ZwGImh7itVymNlWWgpnlV3XUpkRZ4TWBFp55U1dVLmPuDUSTlTVy98Q3bkyXfYnRlSqKT5krshEGMQ2BY0McXG7jysTLcMd2MTG/ABB54XnfHoMCmIaBPY2ILIPPYN0k+Ok9pLsgLdbmu2FK6RBnKcGBNcjBJqF0kesquP/6ank/zbq0FnqoZIg2WIX2mboIgkEQoQDEdD/O/h5cGnYxp4JywvYexI36C2Z04TX961i98DvsqQ9O3FAVnYxHBCIGeC59T4IMuGQNNvg+9qn0A1rzqvK/Qg3r7B6tVqJDzDq+AmOS8uPUpu7GBL17ctzQnNrNxAOaPi7BRUKX8doK0vnOngzgMlTEHmax78qI2IQBVvH59Yg7Q39RhBtCIkdwjFKYMLJeKmW2K5BNkgCS23JWcG8edQMfizn4XnT5Y8VruW5v9ybi//jAz0owEhRmZS9oz6VA4dc6d8rViT/Wyr/cHKRMjj2vMb36xsscmO+dbmzXRp/T1jGQiBNYUOR0NjnzNZjbmHRuesKNupeKD3mZrvG+hRyAHrW72RBNDP4Scpu3Dva+cDyqIUaT5QmEEb3k3wxmOtZpf8/oQP0WFv/xBqRiU0fvtsFMtH612BQJHoKvCRw== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_06="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvvAAYqnSegro5vcAw98fSMSF2Zbzh9zjxnLN2uK1z7Ru/n/o4YRixK9yHoJ1lbG9eWBPy5W/OqCZHsOSzIMULCibX4PJer6UUqDz6IWOvVTtHvJipiIDFcPhV5unVBxNhTTzvc9c0BeBTOBA4nOaZwF7N4YVqOsmJFjqQe1FR3wRxWvuDS/xC/XYM/CGUowhJqhB4LqTUk5lYqG2vuoasIoCNRICOXkYFTbNbbsm0ioFv/yb1ynnsZUPwfFn7UXNnbt5VD+jAN4WHsvJAjbbj5GkHKRzfdHaJOpIivTHLEOqsdnveRb0B1zBhscQKc//iS4l+yd9a4U8TrXWLkSOVR5YZtebsvAVThaIN+kiUog5R9t50Prd4VpHbM3c0m3By6MAh2xaUz0q28kIiEnAcXINssoS1RRFMbfrNrFqfvLR8D7Hci4d/lTgGZhERbVl+4mkU/jQhN6paipXJJYNTEudU92N6MU4UOUI0lBl6oK0ck++Wg/YSYX+NhWxRzQSeMex4EVgURduY5anco+ca8EknNbiaKQQ38G+VmXgsn6OaBvVTxfqS9jwqDJ4aCqvevgwfMzzTTZhAdEXupNOPN8t4+3FfmxPC2HpA1LBwCANJxpcLHjQKuQu5sArt9KDzHO0NL8rKynL76Z/SQRWX36xaCY2sUL5RS6PkA49R2Q== ed.barberis+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_07="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD24LU5iz7KYgpHjDIjanixi/l6e5g9s7ZHG9yGoIKhrx8vcVuTV2s0Awk+kZPCnQjZDC037qPHItryzc++omNKhBVGNZa3Nx+QvBwmF1rGZedQ19JYstEeOXZpCVDTupnGeHqwu/+EqDiE3+tyNfXT0jWgPI5+5eRnZ2c30thhLugtVNv7d1/gU1FleGgaIKTbfkWTWVxV3U6PxuXJPCTN+l+S3EmEhZlDoY/qJ3py0KwhgAT2n7eGumUnvHguq01cprLVeUaHvncPOv4DNpGwjLgN7rdj/ZC9mtHBtSQeq/asEP6upfexTTj2KSXFctWSFNPAbDcVDl6fSy1HhLBMn3dBZBXJDvwrhu0tHuz1SWC8dV7JDjHwdi3zwmeCi9f6VvwsGMCbCWqVb6Kr9+3MGoz9lFBvN+9JEjkbxAx0Bc2aHSRbE2ZjpikiJ49QNnWX8Z4dNhyBT2zryIljKu5nzmtgPnkoarnYKQqt2I4Do6EOZ7BOjZFFJmcHET3zauSlqWeBVV3amvjsR1BHvU0e1FhKxvEBY3QA2zc4+UdtmwIR1kgc0YvgUOHU5Mt1h3DuXUFVUFSpTvzOtaS8TG7gdsDPblOipyW2RpGzYQGPVYs6mH7oCsQNrXSPJPhyAsTo0BHTlDugSL88i/It/I7Ljs/kpRWaIJAKJCIwjk9wQw== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_08="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeV+SMmfQyUXpr9SfKDMZg0QWTg5X/ymBv0Yu7dDkDCzLRJRoQpJh2Dk3/Aumegz1sxyWQnha5Lfpj9sE2tYq6k9qJnCF1efsEG8Lgc3wyBojNfiW6v8N5ekn9ZqzodC+rNhteTitI5BePvnTZmWJBNmz5aUUlQKfQqtSgW/xJy7mWsGzHgLkUhcaFjfugOW1zDkSEJdqclAFhVhnYbxuM4ecF1LiS5iWy2I/BenysUyN9ChFVhMtYSNORDo/0E4ftti+iFPbbupzGyE2nwCIc4SammIOEqm7DLwmUBfxI47d5KP+DNv0ycYWNQam3Sq8EJmLty71KnTXq+hitV6e+YHEzk8eoIdGALTcvKgyhcRXzPIIeKqSfPeN6zd3jHQsKt9/8FFAOfhNHdBGMNDulHRwpPG3thtcH/RWcr599sIAeTEy1DG5acFW0rtLJYM4hXCvuy0eN2JrUEAzBxWu9+iAXKKnWNFZhlafZEfUyMFyON6cbrMwt0TqFSnB1FQcDu5X/H+mGlySTz0bmxedxv7mwmQ3t+xc5VF0RMmzp3mvs3pdsD4g7qm7/hyzYtgoso1OjM2PekqLIY8Hn/0kR0yRlXZm3Ko5ODY0KKFHWb+xTwmDYjIjppsgE9IrrhSRORLcAhLPZzYCOK4Eq2/wYh9kDGU7GV2MxbUoX9a4jRw== ed.barberis+975944588697@cloud9.amazon.com"
aws_cloud9_public_key_09="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoy2S+6UkE3xLPOehCR7eXcqlG0djS/PsIRv+YYO+0MfKBfvVG4hZOhiVPfcyv0XcCSmk4H6NWGHEdfo8PrPs40nMwdZnBvarekK3580X7melF9zF8c/nA1PL4B8WbbFE96Ny30lm98Ji4ZbyCh0xgr1J68jcZuZIyoeqigKYH5lcpJoUWN6vG7jFCI/JEB975U9kGHDcIkSvLib2C26oszfkKw67UXCOdWeT8mEYm8hKrVPTXssjpM+8VxkMBQBZVZ+UOcwx8hCFx8wYeOV67CnJtegUySTsxVoUo1sK7Dw3QIEI9HqcTnqssF+C5neEHCmeYn5H8hmpFxnFipJBMtuCneHstJnd0qSuLS6eZe8rHRdQVQ+1sOnC2TplF+9s/7Tn9SlTB6K5jq1FLsegOyoxgDlOvX36f0q86MtqosW33Uxp47f5KtoXwaeV18N/fqeHV3o9sgq0DlCY4goxRUMN/4y2gLjzQREaZtsLZf7c5IZP7fuXWxicr2YBSsEmUsn9U7T/dCWSKZ1ijuu9hFVcApb6P8Afv15pHW0sL4xdvQNZaStP15CVNHHjfhJmNJAOrk8SPDhk4f2SZ++qLM9HZ2/CnduwlwlKLnV6YFXWgpycztWr34Kor885v4TqojWXuoqZv3D0JNaZ3+Y4UlmZlw4njlEjarROLC/Xk5w== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"

# public keys from appdynamics channel sales team accounts for james schneider.
aws_cloud9_public_key_10="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDtrCQdSgE2Ct8Rufb2i5g7NVkG1Ynq4QW/x76L/ESJBreBdoWdE1v/y0xgaeXTPx3W0CZXnkVvoQIycHmNsUHvtaLaPAoWYEkPNxa9/6iM50ngZl3aFDImNLdial7f4j6yrgu+uGHDgWwCt0FKV0AItgDLW0xJAcYpa7at3eiBCGAYv00r6HqpEZTUYZ8np+3XTMAjb3Wx5erJ8ab1BqiJudoXmhBUHhYK4qtLulB9mOSRAfs4yP8Lg07a22fXqDXDsAOUACN5gWNct+uRO0zHy0/1AyiairJvlne0jgnKu8JXSztXms4be6QMFSlLi1heygNIHTXq3+IUOUkdea2tsdbX1UghGios7DLQ0nNJGBEW1qD7b2Q7yejl8avru7zYYVLlRWjlPggmGG5wup1PNxh5Ecctk9PRLTgXmjuq6rjmDMfW+ng0HHaQKUXjZ83kOQg1x/QSv2jmu8g8ixhBkTkb6oIZxKLwlG7nEJ+qzDPCHVfDZ/gWO9+C0jU0+Q6YLZiWBXKTdYOLhOrqhM1xoElcuHnhJRpCBSaIZoSK49yDdVUva2ZLZWWqFZZbr9gaixiyPc7Yu9K+KfuPN4mEvKgWbpwlUo2DNoRUSeS7RophfCC7lZ70NWk2iE2eX8X1qVYEKiRa80nHTM2SVOPJZzxaEsuEIkX815p8XU+bBw== james.schneider+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_11="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6hYtIrTPF00s0tXWwssI32TdDUzrVYWiHJDoKxstXlkVflsb7BVFSNaQdb3Z8hjnaSI2pP9+6zX9pGuXCqchEWw+QD96jnRzas87sdx5+DmSZPok+t3d60TJt/4YSSY5X9JlEkfDRlm3cKImPsoTKAptW/VON7wiWpwuNBHu7tb7rPZ2ndB4dKi5WPAiNEDh7xYpdgFYhR508N7gx4NiDJ1ziGdEtDeCRdEpCeed/xZC+vew+tSglI01j7+d+U3MzR7SFChCEAoHIPGUvca/sKlkyMnKzekZU3u2j7G9Mrb2dNWsEMf/RdWqquQmn0HAlmU1K+fxNwGuP+PzYM7Q0GZfv5OaNL932bfxcO6qddw2dkJOvEFv0aC3OuOwPwMvojf5J4S9Aki5Qc0qDeCTiKsqKMmYiPsQ5dkcsU50rjUQbLWqdKO1KMT2q8Mnr8/rZfDPbfvywgio6fyBL3O3goTUrgqx15t3vsJO4TCgaCZkzcxk/FANbciz35bq5I1V2fngth9a0iwSNpK2TpiIKlKmCAKEZXBcjxHLGCHF6kE8cNIDnMkpKUK1q74XjAysXL8VoT7qfoWGQiRVPbU/QEbfZCG3sc0HikYDVMM2W8U/eaiqrKMTZn7otTYdH4Lo2fTtkW8vh9N3CAT0nh6+cM0rB+hSSNjl2jJ9n0UumeQ== admin+395719258032@cloud9.amazon.com"
aws_cloud9_public_key_12="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsaMxabVbUscPI8I/f0yecMQWdCKlmrIeLN4bDTuAQpEZS3BHXx+hr1I/i6xi4K7gxLYyQN/wQwEX8J4YJhgM1xTIYlkKoI9BqRRLqjjm1Z4bPnVUR8GtTvF3A0Z0Aecua3zCig8Vw6nNPM12HjV9KptCSqX0fRyKjUVIMax7mmj1kvGgkeT6SeG/l5JJlnVXSWhitiWthFLyZ7wM5iodo1q4yiyqUNh/GgV1Xf4/puEhXwdSK30NLD2aoqZKh/bejntUMdw66VAlon1PtvSDpbUQqlelyMnwnoOgYE23hlVmBhg3hJX5guXhBxjANuRTezY8U7/mp2BFgnlpbi45vGqWA0tAyI8obFNXPB79gYOYVJ1vGb5O2SXMp0NelhhEQ3LUZVU1SyvjGgD+HLv33J+sZrvJxoNP2aVnwgh7hSWyXq+Taqa4Z3afVBaEuI7S6/uIAGOYlq/gvSBLlqthoMV6ZA83cMXoMfHqTOarmUrwJzhJumDUuITNmuJclyHs+YRGaoBoisFtKl7uFoGHNpYQy2iQshcK42xkltvMUxgpDubK+NADAJB0k2XEoQeuQFQVbNdVlKcr/PCMM4tlb1qNoqwX3ERtEikygHVfM+3ngF+MMUcLF9rGdPfiDwaeKSbKEHbYjXb2bAhF5Rz9cp0aEpfOVbzYFjKp2SF5WVw== james.schneider+975944588697@cloud9.amazon.com"
aws_cloud9_public_key_13="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCz2DnYKFZ0oj197z6hLvyBTNvA5UBYa+kbTOuPV0brphZxCspxQ4PLTdWyPIP+qO6aWvvXf3OEKJBWzKj9b4MkbayEWvrljVVOT/ndE+4NdbHjsEWpSAtfxx7h8ADD99iUSr9eHE6+hCLsiIM/TyIXtUK/6ToYX4XOK6ez32BcpoZcxJfR2tT0WwIvVmnnF7FngvPXbBXsvkntwa5RG8KJdHC2tvexHIDm8AShuOLAplSyBL8tzrJHOheBykVOlaowLQoNGOeAYLnsMEzOvbQ5KymKxlPcLRulsFuDvs8yVtCqctTzdWZPLnZNr4uUtjH/2LlID9Hq9rAdEAdskWZapddTh3r7bX81v0Tf+Hkuy6+hKcyQNKzOaodSMBXusje9NKCEkqXFM2kDFSv3gdfNLt9X8dMxLFWluieAv0r2xHrk6dzjHuMMBiHQz05dzI3g71AtrOTUDGX3rj5/sEeHCpeAjZr/bqwq5kbmNPbukek3Jc/g+ybLzxpouwd36lepkLckH24vZ+ySYcMumzBrHTm3Y9FF+PXhIZMW+e2/n+Aj16n+UnQNXQl7FVadNrwHN0QOp51L19guGV9jUVj8R4cUTc6dNXy9s3Qk4cJbQloJ6LJAwqz9W7hE8zRogWELoLKnr/0agCguN38wkYy1SVXLI/ktksIUQ1OjokLdlQ== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"

# public keys from appdynamics channel sales team accounts for wayne brown.
aws_cloud9_public_key_14="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2SOn8ufZigQiiHz+d4ijkgA3g97/PAYi3QfMtW7XzT/t0sHcQ4a9wKVN69YZN4skIzh1FwklzwlhOelvWuJWQ8l3vSPsgObF0hLyYIo9+E9n7OCUveHZvSLZS8duCbHazSQRKKCkHvtg0Vwx8Zyn889bypvEB+UvoAUGOoJchc9+ntUZ+DsaduSD+Xm6YnE0oIQBe6TDyZzAWGfCanfUg7q0Rpri9MlOEed0TyAHFDtVG9qyK3co/wilZcrGDQWTphbQEpUOJ/IYnqlcnpnu/u5pqMAu/Cx958/JgUR1EZI3wwslTLmPINQTg7dJ45VIcqAhcoIabPk99RpeQhDKK2A0/Slyn0wtp4oTru0leYXJl3ZzR2oa7R4pEAeoI2kuv5z8FTIQVuxHSLmoi9zXuV6HVSW1ovKwNllASk4nRg4+9zpjE6QcH9CM0vLH28fRhqtguO0T5kA6HgvUJGuVv7MAG5jL/dXQOYLhXSUFsgviyKzr/Lf/Ww3PPdoClpS3f2W5NqT7ofvpIp7mgWf++B7+b1vJLMosY7ARUrBbA0jdZO9Z3vQ8Ly5IwqfGEYmrM08NhMFumDKgB33eJueoAELrhllmA6WLN04yAaNzC7twVIo9D0/sg1FjVMzYodRAS7aIYQSbRrvsZRCRqfgA+g1H65ME4WQuEWPAyX2znxw== wayne.brown+975944588697@cloud9.amazon.com"
aws_cloud9_public_key_15="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6O+ItfkBs4Jx8vKgnoE/Vz3gYOkhVXkXp/7afKol5PKWWVTr/vl+dtgBtChGQTb5+O3WbMGhimnraF0atWWbmZNnJwnRr3lapLU4jkfdF2TdhTkqrwzOGslcgdKR+Qr5U9AdFMtH6CPWBkN6/hg4JlagNdNHrfH5gKLxwU3OwsXVowVMlw6U20wsHmz3R5tduxBc3NoRqo9aT8EGP7FSbHNGADv30j8BcoLPsQxclh7pWrw3GE0UTHP/OKdG3LqAXZKT2GMNdw1DtOpu2tqtnUcfFSrGuXhSdJNZpEyQQmP5tzjBXWx6QFijYX13x3USift96tg6JElklV+qpYFs4/oGHO2xq5j3KW0afdJbiW+29i1dDTakEFacFl2S+2M9wyJwkHTuXmP5tCZ1bb/mDsUhNvNzboxBQFLsEFAlHCLIRbYSJa1fsKSdonRTl6MY3O+HCp0lEu/1go9JdOMH0iRJdH6Fw4mN3Z0krOvpp9+wIqYyG488y9NViYERJmr1zH1AOpcVsHsqi7J7nqGHM+87wOLYXYpGjNrhD5vQcnrpUOU9TFVeuFX+a62tSwilYEf7O4NVk0x1qvek/uK0kk/RUq0hceEMJdI3+PrlFp7a811yB7p1B0+B6NMb5JU9sUMxBcSq3pSYwnp+izEJgq7N8rIUkWBW0OmurkSkuMQ== AWSReservedSSO_appd-aws-975944588697-dev_35531c6d12fd4c96+975944588697@cloud9.amazon.com"

# 'grep' to see if the aws cloud9 public key is already present, if not, append to the file.
grep -qF "${aws_cloud9_public_key_01}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_01}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_02}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_02}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_03}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_03}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_04}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_04}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_05}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_05}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_06}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_06}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_07}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_07}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_08}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_08}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_09}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_09}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_10}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_10}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_11}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_11}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_12}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_12}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_13}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_13}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_14}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_14}" >> ${user_authorized_keys_file}
grep -qF "${aws_cloud9_public_key_15}" ${user_authorized_keys_file} || echo "${aws_cloud9_public_key_15}" >> ${user_authorized_keys_file}

chmod 600 ${user_authorized_keys_file}

# delete public key inserted by packer during the ami build.
sed -i -e "/packer/d" ${user_authorized_keys_file}

# configure cnao lab environment variables for user. -----------------------------------------------
# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# set cnao lab environment configuration variables.
user_bash_config_file="${user_home}/.bashrc"
cnao_lab_number="$(printf '%02d' ${lab_number})"

# save a copy of the current file.
if [ -f "${user_bash_config_file}.orig" ]; then
  cp -p ${user_bash_config_file} ${user_bash_config_file}.${curdate}
else
  cp -p ${user_bash_config_file} ${user_bash_config_file}.orig
fi

# use the stream editor to substitute the new values.
sed -i -e "/^aws_region_name/s/^.*$/aws_region_name=\"${aws_region_name}\"/" ${user_bash_config_file}
sed -i -e "/^aws_eks_cluster_name/s/^.*$/aws_eks_cluster_name=\"${aws_eks_cluster_name}\"/" ${user_bash_config_file}
sed -i -e "/^cnao_k8s_apm_name/s/^.*$/cnao_k8s_apm_name=\"${cnao_k8s_apm_name}\"/" ${user_bash_config_file}
sed -i -e "/^cnao_lab_id/s/^.*$/cnao_lab_id=\"${cnao_lab_id}\"/" ${user_bash_config_file}
sed -i -e "/^eks_kubeconfig_filepath/s/^.*$/eks_kubeconfig_filepath=\"\$HOME\/.kube\/config\"/" ${user_bash_config_file}
sed -i -e "/^cnao_lab_number/s/^.*$/cnao_lab_number=\"${cnao_lab_number}\"/" ${user_bash_config_file}

# configure the hostname of the aws ec2 instance. --------------------------------------------------
# export environment variables.
export aws_ec2_hostname
export aws_ec2_domain

# set the hostname.
./config_al2_system_hostname.sh
